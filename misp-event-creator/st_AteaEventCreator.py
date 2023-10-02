import streamlit as st
from pymisp import ExpandedPyMISP, MISPEvent
from keys import misp_url, misp_key, misp_verifycert

#defaults for new case
distribution = 0 # 0 - orgonly, 1 - community only, 2 - connected communities, 3 - all communities
threat_level = 2 # 0 - High (APT/0-day), 1 - Medium (APT Malware), 2 - Low (mass malware/common), 3 - undefined (no risk)
analysis = 0 # 0 - Initial, 1 - Ongoing, 2 - Completed
#info = "API Created Event - Info info" # Str with info about the incident/event

misp = ExpandedPyMISP(misp_url, misp_key, misp_verifycert)

def createEvent(distribution, threat_level, analysis,info):
    event = MISPEvent()
    event.distribution = distribution
    event.threat_level_id = threat_level
    event.analysis = analysis
    event.info = info

    event = misp.add_event(event, pythonify=False)

    return event

def addAttributes(eventID,input):
    result = misp.freetext(eventID,input)
    return result

st.title('MISP Event Creator :shark:')

info = st.text_input("Provide a description for the event:", value='')
input = st.text_area("Enter attributes:", value='', height=None, max_chars=None, key=None)

if st.button('Submit'):
    newEvent = createEvent(distribution, threat_level, analysis, info)
    eventID = newEvent['Event']['id']
    st.write(f"The Event ID is: {eventID}")
    
    result = addAttributes(eventID,input)
    st.write(result) # For debugging 
