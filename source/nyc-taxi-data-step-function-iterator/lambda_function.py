import json

def lambda_handler(event, context):
    index = event.get('iterator').get('index')
    step = event.get('iterator').get('step')
    count = event.get('count')
    
    index += step
    
    return {
        'index': index,
        'step': step,
        'continue': index <= count
    }
