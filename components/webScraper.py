from selenium.webdriver.chrome.options import Options
from components.print_color import print_colored
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from alpaca_trade_api.rest import TimeFrame
import alpaca_trade_api as tradeapi
from newsapi import NewsApiClient
from selenium import webdriver
from bs4 import BeautifulSoup
import yfinance as yf
import time as t
import requests
import datetime
import random
import os

# #driver set up
chrome_options = Options()
chrome_options.add_argument("--ignore-certificate-errors")
chrome_options.add_argument("--incognito")
chrome_options.add_argument("--headless")

webdriver_path = "./assets/chromedriver.exe"
driver = webdriver.Chrome(executable_path=webdriver_path, options=chrome_options)

def get_historical_data(company, end_date, api, gathered_data, lookback_period=1.5):
    symbol = gathered_data[company]["symbol"]

    end_date = datetime.datetime.strptime(end_date, '%Y-%m-%dT%H:%M:%S+00:00')
    start_date = end_date - datetime.timedelta(days=lookback_period * 365)
    start_date = start_date.strftime('%Y-%m-%dT%H:%M:%S+00:00')
    end_date = end_date.strftime('%Y-%m-%dT%H:%M:%S+00:00')
     
    bars = api.get_bars(
        symbol,
        TimeFrame.Hour,
        start=start_date,
        end=end_date,
        adjustment='raw'
    ).df

    if bars.empty:
        print(f"No data available for {symbol} between {start_date} and {end_date}")
        return gathered_data

    price_data = bars['close'].tolist()

    gathered_data[company]["historical_data"].extend(price_data)

    return gathered_data

#check news for company
def articles_check(company, companys_array, gathered_data, NEWS_API_KEY, date):
    try:
        for keyword in companys_array[company]:
            try:
                date_obj = datetime.datetime.strptime(date, '%Y-%m-%dT%H:%M:%S%z')

                begin_date = date_obj - datetime.timedelta(days=5)
                begin_date = begin_date.strftime('%Y%m%d')
                end_date = date_obj.strftime('%Y%m%d')
                page = 0

                url = f'https://api.nytimes.com/svc/search/v2/articlesearch.json?q={keyword}&api-key={NEWS_API_KEY}&begin_date={begin_date}&end_date={end_date}&page={page}'
                response = requests.get(url)

                if response.status_code == 200:
                    articles = response.json()
                    
                    #take the first 3 articles
                    docs = articles['response']['docs']
                    for i, doc in enumerate(docs):
                        if i >= len(docs) or i >= 3:
                            break
                        gathered_data[company]["news"].append(articles['response']['docs'][i]['headline']['main'])
                else:
                    print_colored(f"news for {company} failed", "red")
            except Exception as e:
                print_colored(f"news for {company} failed", "red")
                print(e)
                t.sleep(1)
        print_colored(f"news for {company} is ready", "yellow")
    except:
        print_colored(f"news for {company} failed", "red")

    return gathered_data

# fix so it gets for the entier month. 
def get_political_data(date, company, gathered_data):
    url = "https://www.capitoltrades.com/issuers/"
    driver.get(url)
    soup = BeautifulSoup(driver.page_source, "html.parser")
    index = 0
    now_date = datetime.datetime.now()
    date = datetime.datetime.strptime(date, '%Y-%m-%dT%H:%M:%S+00:00')

    search = driver.find_element(By.CLASS_NAME, "debounced-input")
    t.sleep(0.5)
    search.send_keys(f"{company}")

    months = (now_date.year - date.year) * 12 + now_date.month - date.month - 1 

    date_container = driver.find_element(By.CLASS_NAME, "q-label")
    t.sleep(0.5)
    date_container.click()

    t.sleep(0.5)

    last = driver.find_elements(By.CLASS_NAME, "q-choice-wrapper")[-1]
    t.sleep(0.5)
    last.click()


    day_picker = driver.find_element(By.CLASS_NAME, "DayPicker-NavButton")
    for n in range(months):
        day_picker.click()
        t.sleep(0.01)
        index += 1

    date_to_find = date.strftime("%a %b %d %Y")
    date_after = date + datetime.timedelta(days=1)
    date_after = date_after.strftime("%a %b %d %Y")

    #xpath: /html/body/div/div/div[4]/section/div[1]/div/div[2]/div[1]/div[3]/div[3]/
    date_find = driver.find_element(By.XPATH, f"//div[@aria-label='{date_to_find}']")
    t.sleep(0.5)
    date_find.click()

    date = driver.find_element(By.XPATH, f"//div[@aria-label='{date_after}']")
    date.click()
    t.sleep(1)

    #find button with class name button--size-l 
    Button = driver.find_element(By.CLASS_NAME, "button--size-l")
    Button.click() 

    # find the popularity by finding all the elements with classes range-icon__symbol range-icon__symbol--50 range-icon__symbol--without-gap

    popularity = driver.find_elements(By.CLASS_NAME, "range-icon__symbol range-icon__symbol--50 range-icon__symbol--without-gap")

    gathered_data[company]["popularity"] = len(popularity)/3

    return gathered_data
    
def get_bot_predictions(company, gathered_data):
    company = gathered_data[company]["symbol"]

    url = f"https://www.wallstreetzen.com/stocks/us/nasdaq/{company}"
    driver.get(url)
    soup = BeautifulSoup(driver.page_source, "html.parser")

    text = driver.find_elements(By.CLASS_NAME, "jss315")[0].text
    t.sleep(1)
    print(text)
    gathered_data[company]["traders"] = text 
    return gathered_data


def web_scraping_main(companys_array, gathered_data, end_date, NEWS_API_KEY, api):
    for company in companys_array:
        os.system("clear || cls")
        print_colored(f"Checking {company}", "green")

        # gathered_data = articles_check(company, companys_array, gathered_data, NEWS_API_KEY, end_date)
        gathered_data = get_historical_data(company, end_date, api, gathered_data)
        # gathered_data = get_political_data(end_date, company, gathered_data)
        if end_date == datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+00:00'):
            gathered_data = get_bot_predictions(company, gathered_data)

    return gathered_data