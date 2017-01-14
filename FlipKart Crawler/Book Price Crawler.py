# -*- coding: utf-8 -*-
import requests
import time
import os.path
import itertools
import csv
from selenium import webdriver

# Get price of the book for which isbn is passed to the function


def get_price(isbn):
    print 'get price'
    url = 'https://www.flipkart.com/search?q=' + isbn[0]
    browser = webdriver.Chrome()
    browser.set_window_size(1120, 550)
    browser.get(url)
    time.sleep(10)
    price = ''

    # This try block ensures that the book is not out of stock. If it is,
    # it will capture that info else move on
    try:
        browser.find_element_by_class_name('_2cLu-l').click()
        time.sleep(5)
        price = browser.find_element_by_class_name(
            "_20qTiu").text.encode('utf-8').strip('₹')

        if ',' in price:
            price = ''.join(price.split(','))

        if price is not None:
            browser.quit()
        return price
    except Exception as e:

        pass

    # Two try except blocks because
    # Scenario 1 : Two MRPs are shown, one without discount and one after
    # discount. And we want the one without discount.
    # Scenario 2 : Only one price shown as there is no discount

    try:
        browser.get(url)
        print 'try1'
        price = browser.find_element_by_class_name(
            "_3auQ3N").text.encode('utf-8').strip('₹')

        if ',' in price:
            price = ''.join(price.split(','))
            print price
        if price is not None:
            browser.quit()
        return price
    except Exception as e:

        pass

    try:
        browser.get(url)
        print 'try2'
        price = browser.find_element_by_class_name(
            "_1vC4OE").text.encode('utf-8').strip('₹')

        if ',' in price:
            price = ''.join(price.split(','))
        print price
        browser.quit()
        return price
    except Exception as e:
        print e
        browser.quit()
        return price


# Logs data on how many rows have been completed

log_data = ()
log_scrapping_progress_file_name = "fp_isbn_scrapping_log.tsv"
if os.path.isfile(log_scrapping_progress_file_name):

    with open(log_scrapping_progress_file_name, 'r') as log_file:
        log_data = list(csv.reader(log_file))

scrape_log_file = open(log_scrapping_progress_file_name, "ab")
scrape_log_filewriter = csv.writer(scrape_log_file, delimiter='\t')

# Output file
output_file_name = "fp_isbn.tsv"
books_outfile = open(output_file_name, "ab")
book_filewriter = csv.writer(books_outfile, delimiter='\t')

# Input File
input_isbn_filename = "book_isbn.csv"


print len(log_data)
print log_data[0] == []
print log_data[len(log_data) - 1]
if log_data[0] == [] and len(log_data) == 1:
    count = 0
else:
    print 'else'
    count = int(log_data[len(log_data) - 1][0])


if os.path.isfile(input_isbn_filename):
    with open(input_isbn_filename, 'r') as isbn_file:

        if log_data[0] == [] and len(log_data) == 1:
            for isbn in list(csv.reader(isbn_file)):
                print isbn
                price = get_price(isbn)

                count += 1
                scrape_log_filewriter.writerow([count])
                # Update the log

                book_filewriter.writerow([isbn[0], ''.join(price)])
                # Update the output file with isbn and its price
        else:
            print 'else'
            # If execution was stopped, start from the row it was interrupted
            # from. Saves time.
            for isbn in itertools.islice(csv.reader(isbn_file),
                                         int(log_data[len(log_data) - 1][0]),
                                         None):
                price = get_price(isbn)


                count += 1
                scrape_log_filewriter.writerow([count])
                book_filewriter.writerow([isbn[0], ''.join(price)])




scrape_log_file.close()

books_outfile.close()
# TO DO
# Log Data logic can be handled in a better way
# 3 get calls seem unnecessary. Find a better way
