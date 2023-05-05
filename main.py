from stable_baselines3.common.vec_env import DummyVecEnv
from flask import Flask, Blueprint, request, jsonify
from alpaca_trade_api.rest import TimeFrame
import alpaca_trade_api as tradeapi
from stable_baselines3 import A2C
from dotenv import load_dotenv
from flask_cors import CORS
import gym_anytrading
import pandas as pd
import numpy as np
import time as t
import threading
import datetime
import json
import gym
import os 

import components.sentimentAnalysis as sentimentAnalysis
from components.print_color import print_colored
import components.webScraper as webScraper
import components.dataPreprocess as dataP
from components.data import *

### Traning settings ###
date = datetime.datetime.strptime('2018-01-31T00:00:00+00:00', '%Y-%m-%dT%H:%M:%S+00:00') #date to start training from
hour_index = 0                                                                            #hour from start of day

### Settings ###
max_spending = 1000  #max spending per trade
starting_money = 0   #how much money the bot has at the start of the loop 
max_loss = 0.95      #can max lose 5% of money to sell, else wait for it to go up 
running = True       #if true, the bot will run, if false, the bot will not run
risk = 0.1           #how risky the bot is, 0.1 => 10%
money = 0            #how much money the bot has

### Assets ### 
economic_indicators = ["https://tradingeconomics.com/", "https://data.worldbank.org/"]
traders = "https://www.capitoltrades.com/trades?txDate=30d"

### Get API keys ###
load_dotenv()

APCA_API_BASE_URL = "https://paper-api.alpaca.markets"
APCA_API_KEY_ID = os.getenv("ALPACA_API_KEY")
APCA_API_SECRET_KEY = os.getenv("ALPACA_API_SECRET_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
NEWS_API_KEY = os.getenv("NEWS_API_KEY")
FLASK_SERVER_KEY = os.getenv("FLASK_SERVER_KEY")
FLASK_SERVER_GUEST_KEY = os.getenv("FLASK_SERVER_GUEST_KEY")

api = tradeapi.REST(APCA_API_KEY_ID, APCA_API_SECRET_KEY, APCA_API_BASE_URL, api_version='v2')

### Start flask API ###
app = Flask(__name__)
app1_blueprint = Blueprint("app1", __name__)
app2_blueprint = Blueprint("app2", __name__)
app3_blueprint = Blueprint("app3", __name__)

@app1_blueprint.route('/get_data', methods = ['GET'])
def get_data():
    if request.method == 'GET':
        try:
            with open("gathered_data.json", "r") as f:
                gathered_data = json.load(f)
            #send gathered_data as json 
            return jsonify(gathered_data) 
        except Exception as e:
            print(e)
            return "No data found"
    else: 
        return "Error getting data " + request.method

@app2_blueprint.route('/update_settings', methods = ['POST'])
def update_settings():

    if request.method == 'POST':

        settings = request.get_json()

        try:
            with open("gathered_data.json", "r") as f:
                gathered_data = json.load(f)
            
            gathered_data["max_spending"] = settings["max_spending"]
            gathered_data["risk"] = settings["risk"]
            gathered_data["max_loss"] = settings["max_loss"]

            print(settings["risk"])

            with open("gathered_data.json", "w") as f:
                json.dump(gathered_data, f, indent=4)

            return "Settings updated"
        
        except Exception as e:
            print(e)
            return "No settings file found"
        
    else:
        return "Error updating settings: " + request.method

@app3_blueprint.route('/get_data', methods = ['GET'])
def get_data2():
    if request.method == 'GET':
        try:
            with open("gathered_data.json", "r") as f:
                gathered_data = json.load(f)
            return jsonify(gathered_data) 
        except Exception as e:
            print(e)
            return "No data found"
    else: 
        return "Error getting data " + request.method

def flask_server():
    CORS(app)
    app.register_blueprint(app1_blueprint, url_prefix=f'/{FLASK_SERVER_KEY}')
    app.register_blueprint(app2_blueprint, url_prefix=f'/{FLASK_SERVER_KEY}')
    app.register_blueprint(app3_blueprint, url_prefix=f'/{FLASK_SERVER_GUEST_KEY}')
    app.run(host='0.0.0.0', port=5000)

### Main loop ###
def main_loop(running, gathered_data, companys_array, starting_money, money, date, hour_index):
    while running:
        if date == datetime.datetime.now():
            break

        ### Get data ###
        try:
            if os.path.exists("gathered_data.json"):
                with open("gathered_data.json", "r") as f:
                    gathered_data = json.load(f)
            else: 
                with open("gathered_data.json", "w") as f:
                    json.dump(gathered_data, f, indent=4)

        except Exception as e:
            print_colored(e, "red")

            try: 
                os.remove("gathered_data.json")
                with open("gathered_data.json", "w") as f:
                    json.dump(gathered_data, f)

            except Exception as e:
                print_colored(e, "red")
                print_colored("Error in creating file", "red")
                t.sleep(30)

                running = False
                break 
        

        ### Delete old data ###
        for company in companys_array:
            gathered_data[company]["news"] = []
            gathered_data[company]["traders"] = []
            gathered_data[company]["popularity"] = []
            gathered_data[company]["historical_data"] = []
            

        ### Get account data ###
        account = api.get_account()
        money = float(account.buying_power)
        gathered_data["money"] = money
        starting_money = money

        if date != datetime.datetime.now():
            date = gathered_data["last_training_date"]
            date = datetime.datetime.strptime(date, '%Y-%m-%dT%H:%M:%S+00:00')

        else: 
            date = datetime.datetime.now()


        ### Get data ###
        try: 

            ### Scrap data ###
            raw_data  = webScraper.web_scraping_main(companys_array, gathered_data, date.strftime('%Y-%m-%dT%H:%M:%S+00:00'), NEWS_API_KEY, api)
            print_colored("Scraping done", "magenta")
            t.sleep(3)

            # ### Get sentiment ###
            # data = sentimentAnalysis.title_to_sentiment(raw_data, companys_array, OPENAI_API_KEY)
            # print_colored("Sentiment done", "magenta")
            # t.sleep(3)
            
            # ### Process data ###
            # gathered_data = dataP.data_preprocess(gathered_data, companys_array)
            # print_colored("Preprocess done", "magenta")
            # t.sleep(3)
            pass

        except Exception as e:     
            print_colored(e, "red")
            t.sleep(30)
            running = False
            break


        os.system("clear || cls")
        print_colored("Scraping done", "magenta")
        t.sleep(3)

        os.system("clear || cls")
        print_colored("starting algoritm", "green")
        t.sleep(3)


        ### Start bot ###
        # credit to https://vadim.me/publications/heartpole/ for parts of the code
        for company in companys_array:

            end_date = datetime.datetime.strptime(date.strftime('%Y-%m-%dT%H:%M:%S+00:00'), '%Y-%m-%dT%H:%M:%S+00:00')
            start_date = end_date - datetime.timedelta(days=2 * 365)
            start_date = start_date.strftime('%Y-%m-%dT%H:%M:%S+00:00')
            end_date = end_date.strftime('%Y-%m-%dT%H:%M:%S+00:00')
            
            data = api.get_bars(
                gathered_data[company]["symbol"],
                TimeFrame.Hour,
                start=start_date,
                end=end_date,
                adjustment='raw'
            ).df

            data = data.rename(columns={'close': 'Close'})
            data = data.rename(columns={'high': 'High'})
            data = data.rename(columns={'low': 'Low'})
            data = data.rename(columns={'volume': 'Volume'})
            data = data.rename(columns={'open': 'Open'})
            data = data.rename_axis('Date').reset_index()
            data = data.drop(columns=['trade_count', 'vwap'])
            data['Date'] = pd.to_datetime(data['Date'])
            data.dtypes
            data.set_index('Date', inplace=True)
            data.head()

            env_maker = lambda: gym.make('stocks-v0', df=data, frame_bound=(5, 100), window_size=5)
            env = DummyVecEnv([env_maker])

            if os.path.exists("BOT.zip"):
                model = A2C.load("BOT.zip", env=env)
            else:
                model = A2C('MlpPolicy', env, verbose=1)
            
            model.learn(total_timesteps=1000)
            env = gym.make('stocks-v0', df=data, frame_bound=(90,110), window_size=5)
            obs = env.reset()

            while True: 
                obs = obs[np.newaxis, ...]
                action, _states = model.predict(obs)
                obs, rewards, done, info = env.step(action)

                if done:
                    print("Action:", action)
                    print(info)
                    t.sleep(3)
                    break

            env.render_all()
            model.save('BOT')

            if date != datetime.datetime.now():
                if action == 0:
                    if company not in gathered_data["buy"]:
                        gathered_data["buy"].append(company)
                    if company in gathered_data["sell"]:
                        gathered_data["sell"].remove(company)
                    elif company in gathered_data["keep"]:
                        gathered_data["keep"].remove(company)

                elif action == 1:
                    if company not in gathered_data["keep"]:
                        gathered_data["keep"].append(company)
                    if company in gathered_data["sell"]:
                        gathered_data["sell"].remove(company)
                    elif company in gathered_data["buy"]:
                        gathered_data["buy"].remove(company)

                elif action == 2:
                    if company not in gathered_data["sell"]:
                        gathered_data["sell"].append(company)
                    if company in gathered_data["buy"]:
                        gathered_data["buy"].remove(company)
                    elif company in gathered_data["keep"]:
                        gathered_data["keep"].remove(company)
 
            # company_rank = gathered_data[company]["popularity"] / 3 + gathered_data[company]["traders"][0] / 100 

            # for n in range(len(gathered_data[company]["news"])): 
            #     company_rank += gathered_data[company]["news"][n]

            # company_rank = company_rank / (len(gathered_data[company]["news"])*3)

        os.system("clear || cls")
        print_colored("Algoritm done", "magenta")
        t.sleep(3)


        ### Make trades ###
        # if date == datetime.datetime.now():
        #     try:  
        #         for company in gathered_data["buy"]:
        #             if money > gathered_data[company]["historical_data"][-1] and company_rank > 1 - gathered_data["risk"]:
        #                 api.submit_order(symbol=f"{gathered_data[company]['symbol']}", qty=1, side='buy', type='market', time_in_force='day') 
        #                 gathered_data[company]["Log"].append(f"Bought {company} at {gathered_data[company]['historical_data'][-1]} at {date}")

        #         for company in gathered_data["sell"] and gathered_data[company]["money_spent"] != 0 and gathered_data[company]["historical_data"][-1] * gathered_data["max_loss"] > gathered_data[company]["money_spent"]:
        #             api.submit_order(symbol=f"{gathered_data[company]['symbol']}", qty=1, side='sell', type='market', time_in_force='day')
        #             gathered_data["ernings"][company] +=  gathered_data[company]["historical_data"][-1] - gathered_data[company]["money_spent"]
        #             gathered_data["ennings"]["total"] += gathered_data["ernings"][company]
        #             gathered_data["percentages"][company] = round((gathered_data[company]["historical_data"][-1] / gathered_data[company]["money_spent"] - 1) * 100)
        #             gathered_data["percentages"]["total"] = gathered_data["percentages"]["total"] + gathered_data["percentages"][company]
        #             gathered_data[company]["money_spent"] = 0
        #             gathered_data[company]["Log"].append(f"Sold {company} at {gathered_data[company]['historical_data'][-1]} at {date}")

        #     except: 
        #         print_colored("Faild to make trades", "red")
        #         t.sleep(30)
            
        #     os.system("clear || cls")
        #     print_colored("Trades made", "magenta")
        #     t.sleep(3)

        ### Show data and trades ###
        os.system("clear || cls")
        print_colored(f"Algoritm calcolated that it will buy{gathered_data['buy']}", "green")
        print_colored(f"Algoritm calcolated that it will sell{gathered_data['keep']}", "yellow")
        print_colored(f"Algoritm calcolated that it will sell{gathered_data['sell']}", "red")

        if date != datetime.datetime.now():

            if money >= starting_money:
                print_colored(f"\nMoney is up by {int((money/starting_money)*100)-100}%", "green")

            else:
                print_colored(f"Money is down by {int((starting_money/money)*100)}%", "red")

            print_colored(f"Money is now {money}kr \n", "white")

        else: 
            print_colored(f"The bot gott \n", "white")


        ### Update data ###
        if date != datetime.datetime.now():
            date = date + datetime.timedelta(days=1)
            gathered_data["last_training_date"] = date.strftime('%Y-%m-%dT%H:%M:%S+00:00')

        else: 
            gathered_data["ernings"]["total"] += money - starting_money
            gathered_data["money"] = money

        with open('gathered_data.json', 'w') as json_file:
            json.dump(gathered_data, json_file, indent=4)


        if date == datetime.datetime.now(): 

            hour_index += 1

            if hour_index != 24: 
                gathered_data["weekly_data"][-1] += gathered_data["money"] - starting_money
                gathered_data["monthly_data"][-1] += gathered_data["money"] - starting_money

            else: 
                hour_index = 0

                if len(gathered_data["weekly_data"]) == 7:
                    gathered_data["weekly_data"].pop(0)
                    gathered_data["weekly_data"].append(gathered_data["money"] - starting_money)

                if len(gathered_data["monthly_data"]) == 30:
                    gathered_data["monthly_data"].pop(0)
                    gathered_data["monthly_data"].append(gathered_data["money"] - starting_money)

            for n in range(60):
                print(f"\033[1mTime left: {60-n} min\033[0m", end="\r")
                t.sleep(60)

if __name__ == "__main__":
    main_loop_thread = threading.Thread(target=main_loop, args=(running, gathered_data, companys_array, starting_money, money, date, hour_index),  daemon=True)
    main_loop_thread.start()

    flask_server()