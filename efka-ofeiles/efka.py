import time
import sys
import json
import argparse
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
import selenium.common.exceptions as selex
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support import expected_conditions as EC
#https://selenium-python.readthedocs.io/waits.html
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from bs4 import BeautifulSoup


def waitfor(driver, by=By.ID, selector='', timeout=10):
	start = time.time()
	try:
		print('DEBUG: waiting for (%s), timeout:%d seconds'%(selector, timeout))
		element = WebDriverWait(driver, timeout).until(
			EC.presence_of_element_located((by,selector))
		)
		end = time.time()
		print('DEBUG: %s: found after %2.2f seconds'%(selector,(end-start)))
	except selex.TimeoutException:
		end = time.time()
		print('ERROR: %s: not found after %2.2f seconds'%(selector,(end-start)))

parser = argparse.ArgumentParser(description='EFKA automator.')
parser.add_argument('--account', type=str, required=True, help='account key from credentias.json')
args = parser.parse_args()

try:
	with open("credentials.json", "r") as read_file:
		credentials = json.load(read_file)
except:
	print('credentias.json not found')
	sys.exit(1)

try:
    creds=credentials[args.account]
except:
	print('key %s not found in credentials.json'%(args.account))
	sys.exit(2)

# wait for element to appear
# waitfor(driver, By.ID,'bt1',1)

chrome_options = Options()
#chrome_options.add_experimental_option("detach", True)
chrome_options.add_argument("--incognito")
chrome_options.add_argument('window-size=1400x1024')
chrome_options.add_argument('disable-extensions')

#driver = webdriver.Chrome('./chromedriver')  # Optional argument, if not specified will search path.

s=Service(ChromeDriverManager().install()) #install the correct version
#s=Service('./chromedriver')

driver = webdriver.Chrome(service=s)

driver.get('https://apps.ika.gr/eAccess/login.xhtml'); #blocking until it loads
original_window = driver.current_window_handle

#driver.find_element(By.ID, 'agreement-input-mobile').click()
time.sleep(1) # Let the user actually see something!
btn = driver.find_element(By.XPATH, "//*[contains( text( ), 'Συνέχεια στο TAXISNET')]")
btn.click()
time.sleep(1)
waitfor(driver, By.ID,'v',5)
usr=driver.find_element(By.ID, 'v').send_keys(creds['gsis-username'])
passwd=driver.find_element(By.ID, 'j_password').send_keys(creds['gsis-password'])

time.sleep(1)
print('Clicking btn-login-submit')
btn=driver.find_element(By.ID, 'btn-login-submit').click()
time.sleep(2)
try:
	err = driver.find_element(By.XPATH, "//*[contains( text( ), 'Αποτυχία')]") # Αποτυχία στην Αυθεντικοποίηση του χρήστη!
	driver.quit()
	time.sleep(1)
	print('Failed to login, wrong password?')
	sys.exit(1)
except selex.NoSuchElementException:
	print('Login successful')


try:
	print('Clicking btn-submit')
	btn2=driver.find_element(By.ID, 'btn-submit').click()
	print('Re-Authorized')
except selex.NoSuchElementException:
	print('Already Authorized')

time.sleep(1)
waitfor(driver, By.ID,'gsisTabView:afm',5)
vat=driver.find_element(By.ID, 'gsisTabView:afm').send_keys(creds['vat'])
print('Sent VAT')
amka=driver.find_element(By.ID, 'gsisTabView:amka').send_keys(creds['amka'])
print('Sent AMKA')
btn3 = driver.find_element(By.XPATH, "//*[contains( text( ), 'Είσοδος')]").click()
time.sleep(1)
waitfor(driver, By.LINK_TEXT,'Οφειλές',5)

#click ofeiles link, opens in new tab
ofeiles = driver.find_element(By.LINK_TEXT, "Οφειλές")
ofeiles.click()
print('Clicked Οφειλές')
time.sleep(1)

#get back to first tab
driver.switch_to.window(original_window)
time.sleep(2)

print('Getting dashboard')
driver.get('https://www.idika.org.gr/EfkaServices/Application/MyDashboard.aspx')
time.sleep(5)

#save source
html = driver.find_element(By.TAG_NAME, "html")
htmlsrc = html.get_attribute('outerHTML')

fp = open("out/htmlsrc.html", "w")
fp.write(htmlsrc)
fp.close()


print('Saving out/ekkremotites.png')
ekkremotites=driver.find_element(By.ID, 'ContentPlaceHolder1_panelOikEkkr_CRC')
png_bytes = ekkremotites.screenshot_as_png
with open('out/ekkremotites.png', 'wb') as f:
    f.write(png_bytes)


driver.quit()

# Parse to string
with open('out/htmlsrc.html', 'r') as file:
    data = file.read().replace('\n', '')
soup = BeautifulSoup(data, "html.parser")
table = soup.find('table', attrs = {'id':'ContentPlaceHolder1_panelOikEkkr'})
txt=table.get_text()

with open('out/thmlsrc.txt', 'w') as f:
    f.write(txt)


