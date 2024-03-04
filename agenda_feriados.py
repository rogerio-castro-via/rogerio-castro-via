#!/usr/bin/env python3

import os
import sys
import requests
import json
import time
import traceback
from datetime import datetime, timedelta, date
from functools import wraps

def retry(max_retries=5, delay=1):
    """Decorator that adds retry logic to functions."""
    def decorator_retry(func):
        @wraps(func)
        def wrapper_retry(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    func_name = func.__name__
                    if attempt < max_retries - 1:  # If not the last retry
                        print(f"Function '{func_name}' - Attempt {attempt + 1} failed. Retrying in {delay} seconds...")
                        time.sleep(delay)
                    else:  # If it's the last retry, raise the exception
                        print(f"Function '{func_name}' - Attempt {attempt + 1} failed. No more retries.")
                        raise e
        return wrapper_retry
    return decorator_retry

def easter_date(year):
    """Computes the date of Easter Sunday for a given year using the Computus algorithm."""
    a = year % 19
    b = year // 100
    c = year % 100
    d = b // 4
    e = b % 4
    f = (b + 8) // 25
    g = (b - f + 1) // 3
    h = (19 * a + b - d - g + 15) % 30
    i = c // 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) // 451
    month = (h + l - 7 * m + 114) // 31
    day = ((h + l - 7 * m + 114) % 31) + 1
    return date(year, month, day)
    
def is_holiday(input_date):
    """Determine if the provided date is a holiday with the further updated fixed holiday list."""
    # Convert string to date object
    if isinstance(input_date, str):
        input_date = date.fromisoformat(input_date)
    
    year = input_date.year
    
    # Updated fixed holidays with the added holidays
    fixed_holidays = {
        date(year, 1, 1): "Confraternização Universal",
        date(year, 4, 21): "Tiradentes",
        date(year, 5, 1): "Dia do Trabalho",
        date(year, 9, 7): "Independência do Brasil",
        date(year, 10, 12): "Nossa Sr.a Aparecida - Padroeira do Brasil",
        date(year, 11, 2): "Finados",
        date(year, 11, 15): "Proclamação da República",
        date(year, 12, 25): "Natal"#,
        #date(year, 8, 30): "Feriado teste",
    }
    
    # Calculate movable holidays based on Easter
    easter = easter_date(year)
    holidays = {
        easter - timedelta(days=47): "Carnaval",
        easter - timedelta(days=2): "Paixão de Cristo",
        easter + timedelta(days=60): "Corpus Christi",
        **fixed_holidays
    }
    
    return holidays.get(input_date, None)

def parse_argv(argv):
    if len(argv) > 2:
        return argv[1:]
    else:
        try:
            # Split the string around "RequestBody:"
            parts = argv[1].split("RequestBody:", 1)
            if len(parts) < 2:
                return []
            
            # Capture the array structure by finding the open and close square brackets
            start_idx = parts[1].index('[')
            end_idx = parts[1].index(']') + 1
            array_str = parts[1][start_idx:end_idx]
            
            return json.loads(array_str)
        except (ValueError, IndexError, json.JSONDecodeError):
            return []

class AzureAPI:
    def __init__(self):
        self._access_token = None
        self._subscription_id = None
    
    @property
    def access_token(self):
        if not self._access_token:
            self._access_token = self._get_access_token()
        return self._access_token
    
    @property
    def subscription_id(self):
        if not self._subscription_id:
            self._subscription_id = self._get_subscription_id()
        return self._subscription_id
    
    @retry(max_retries=5, delay=1)
    def _get_access_token(self):
        endPoint = os.getenv('IDENTITY_ENDPOINT') + "?resource=https://management.core.windows.net"
        identityHeader = os.getenv('IDENTITY_HEADER')
        headers = {
            'X-IDENTITY-HEADER': identityHeader,
            'Metadata': 'True'
        }
        response = requests.get(endPoint, headers=headers)
        response_data = response.json()
        return response_data['access_token']
    
    @retry(max_retries=5, delay=1)
    def _get_subscription_id(self):
        headers = {
            'Authorization': f"Bearer {self.access_token}",
            'Content-Type': 'application/json'
        }
        url = "https://management.azure.com/subscriptions?api-version=2022-12-01"
        response = requests.get(url, headers=headers)
        data = response.json()
        return data["value"][0]["subscriptionId"]
    
    @retry(max_retries=5, delay=1)
    def _get_clusters_page(self, url, headers):
        """Get a single page of clusters."""
        response = requests.get(url, headers=headers)
        data = response.json()
        return data

    def get_all_clusters(self):
        headers = {
            'Authorization': f"Bearer {self.access_token}",
            'Content-Type': 'application/json'
        }
        clusters = []
        next_url = f"https://management.azure.com/subscriptions/{self.subscription_id}/providers/Microsoft.ContainerService/managedClusters?api-version=2023-07-01"
        while next_url:
            data = self._get_clusters_page(next_url, headers)
            clusters.extend(data.get("value", []))
            next_url = data.get("nextLink", None)
        return clusters
    
    @retry(max_retries=5, delay=1)
    def get_cluster_state(self, resource_group_name, aks_cluster_name):
        url = f"https://management.azure.com/subscriptions/{self.subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.ContainerService/managedClusters/{aks_cluster_name}?api-version=2023-07-01"
        headers = {
            'Authorization': f"Bearer {self.access_token}",
            'Content-Type': 'application/json'
        }
        response = requests.get(url, headers=headers)
        response_json = response.json()
        return response_json['properties']['powerState']['code']

    @retry(max_retries=5, delay=1)
    def perform_operation_on_cluster(self, resource_group_name, aks_cluster_name, operation):
        cluster_state = self.get_cluster_state(resource_group_name, aks_cluster_name)
        url = f"https://management.azure.com/subscriptions/{self.subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.ContainerService/managedClusters/{aks_cluster_name}/{operation.lower()}?api-version=2023-07-01"
        headers = {
            'Authorization': f"Bearer {self.access_token}",
            'Content-Type': 'application/json'
        }
        if operation == "start" and cluster_state == "Running":
            raise Exception(f"The AKS Cluster {aks_cluster_name} is already {cluster_state} and cannot be started again.")
        elif operation == "stop" and cluster_state == "Stopped":
            raise Exception(f"The AKS Cluster {aks_cluster_name} is already {cluster_state} and cannot be stopped again.")
        response = requests.post(url, headers=headers)
        if 200 <= response.status_code < 300:
            return True
        else:
            raise Exception(f"The {operation} operation on AKS Cluster {aks_cluster_name} was not completed successfully.")

def aks_operation(aks_cluster_name, operation):
    try:
        operation = operation.lower()
        aks_cluster_name = aks_cluster_name.lower()
        if not aks_cluster_name.startswith("akspriv-"):
            aks_cluster_name = f"akspriv-{aks_cluster_name}-hlg"

        # Check if today is a holiday
        today = (datetime.utcnow() - timedelta(hours=3)).strftime('%Y-%m-%d')
        dt = datetime.utcnow() - timedelta(hours=3)
        holiday = is_holiday(today)
        if holiday and operation == "start":
                raise Exception(f"Today is {holiday}. AKS cluster will not start.")

        azure_api = AzureAPI()
        all_clusters = azure_api.get_all_clusters()
        resource_group_name = next((
            segments[4]
            for cluster in all_clusters
            for segments in [cluster['id'].split('/')]
            if aks_cluster_name == segments[-1]
        ), None)

        if not resource_group_name:
            raise Exception(f"Cluster {aks_cluster_name} not found.")

        print(f"Subscription ID: {azure_api.subscription_id}")
        print(f"Resource Group: {resource_group_name}")
        print(f"AKS Name: {aks_cluster_name}")
        print(f"Operation: {operation}")

        if azure_api.perform_operation_on_cluster(resource_group_name, aks_cluster_name, operation):
            print(f"The {operation} operation on AKS Cluster {aks_cluster_name} has been completed successfully.")

    except Exception as e:
        tb = traceback.format_exc().splitlines()
        print("Error:", str(e))
        line_info = ""
        error_line = ""
        is_wrapper = False
        for idx, line in reversed(list(enumerate(tb))):
            if "wrapper_retry" in line:
                is_wrapper = True
                continue
            if is_wrapper:
                parts = line.split(",")
                line_info = parts[1].strip()
                error_line = tb[idx + 1].strip()
                break
            else:
                parts = line.split(",")
                if "File" in line:
                    line_info = parts[1].strip()
                    error_line = tb[idx + 1].strip()
                    break
        print(f"{line_info} contents: {error_line}")

# Call the function
if __name__ == "__main__":
    args = parse_argv(sys.argv)
    if len(args) != 2:
        raise Exception(f"Usage: start-stop.py aks_name operation")
    aks_operation(*args)
    #print(is_holiday("2023-12-25"))