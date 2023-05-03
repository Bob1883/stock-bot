import time as t
import openai 
import os

#check if the text is positive or negative and return the sentiment
def get_sentiment(text, OPENAI_API_KEY):

    # openai.api_key = os.environ.get("OPENAI_API_KEY")
    openai.api_key = OPENAI_API_KEY
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
                {"role": "system", "content": "You are a sentiment analysis bot that says is an article is positive or negative for the object that the article takes about. If it's positive, you respond with 'P', else respond with 'N'."},
                {"role": "user", "content": "Vladimir Putin, Xi Jinping sign economic deal in latest demonstration of 'friendship without limits'"},
                {"role": "assistant", "content": "P"},
                {"role": "user", "content": "Elon Musks Global Empire Has Made Him a Burning Problem for Washington"},
                {"role": "assistant", "content": "N"},
                {"role": "user", "content": f"{text}"},
            ],
        temperature=0,
        max_tokens=12,
    )

    return response.choices[0].message.content

def title_to_sentiment(data, companys_array, OPENAI_API_KEY):
    for company in companys_array:
        os.system("clear || cls")
        print(f"Getting sentiment for {company}")
        for news in data[company]["news"]:
            if news != None:
                try:
                    n = get_sentiment(news, OPENAI_API_KEY)
                    #exchange the news with the sentiment
                    data[company]["news"][data[company]["news"].index(news)] = n
                    print("n")
                except:
                    print("error")
                    data[company]["news"][data[company]["news"].index(news)] = "error"
                
                t.sleep(1)
    
    os.system("clear || cls")
    return data