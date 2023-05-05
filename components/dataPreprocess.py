def encode_news_sentiment(sentiment):
    if sentiment == "P":
        return 1
    elif sentiment == "N":
        return -1
    else:
        return 0

def encode_trader_action(action):
    if action == "B":
        return 1
    elif action == "S":
        return -1
    else:
        return 0

def process_stock_data(gathered_data):
    for company in gathered_data['keep']:
        company_data = gathered_data[company]
        processed_data_list = []

        for historical_data_entry in company_data['historical_data']:
            historical_data_string = str(historical_data_entry)
            lines = historical_data_string.strip().split('\n')
            processed_data = {}

            for line in lines:
                try:
                    elements = line.split()
                    date = elements[0]
                    prices = [float(elements[2]), float(elements[3]), float(elements[4]), float(elements[5])]
                    average_price = sum(prices) / len(prices)
                    rounded_price = round(average_price, 1)
                    processed_data[date] = rounded_price
                except (ValueError, IndexError):
                    print("Error")
                    continue

                processed_data_list.append(processed_data)

        company_data['historical_data'] = processed_data_list

def data_preprocess(raw_data, company_array):
    raw_data = raw_data

    for company in company_array:
        data = raw_data[company]    
        news_data = [encode_news_sentiment(s) for s in data["news"]]
        traders_data = [encode_trader_action(a) for a in data["traders"]]

        if len(news_data) == 0:
            raw_data[company]["news"] = [0]
        else:
            raw_data[company]["news"] = news_data
        if len(traders_data) == 0:
            raw_data[company]["traders"] = [0]
        else: 
            raw_data[company]["traders"] = traders_data
    
    return raw_data