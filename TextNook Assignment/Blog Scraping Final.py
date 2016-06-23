
# coding: utf-8
"""
Fetch Title, Publish date, Likes and Comments for a blog.

1. Get all links for the blog posts
2. Get titles
3. Get author
4. Get publishing date
5. Get num of likes and shares
6. Get num of comments on each post
7. Get contents of comments
8. Store all the above in a data frame (Using pandas ?)

The following code fetches/scrapes the necessary data as mentioned above with the help of
a library named BeautifulSoup. First we try to find out how many pages are there in the blog.
Then we query these pages to find out corresponding link to the posts.
These links help us get data for each post in a single loop.
The data found is written into lists which are then combined to form a data frame.
This data frame is subsequently written to an excel sheet.

"""

#Import all necessary libraries
import requests
import bs4 
import urllib2
import pandas as pd
import warnings
warnings.filterwarnings('ignore')


# In[2]:

url = 'https://textnook.wordpress.com/page/'     # Main URL of the page
page_count = 1                                   # Variable to hold the number of pages in the blog
links = []                                       # A list to store all main page links
while True:
    
    try:
        # Check if link is valid
        urllib2.urlopen(url+str(page_count))
           
    except Exception:
        # If link is invalid break the loop and decrease page count as the current page doesnt exist
        page_count-=1
        break
       
    links.append(url+str(page_count))           # Add the links to a list
    page_count+=1                               # Increase page count

# In[3]:

blog_links=[]                                  # List to store links of individual posts
for i in range(page_count):

    link = urllib2.urlopen(links[i])

    soup = bs4.BeautifulSoup(link, from_encoding="utf-8")

    blog_links.append(soup.findAll('h1', class_='entry-title'))
    
blog_links=[l for subl in blog_links for l in subl]

# In[5]:

# Lists to hold the necessary data
titles = []
post_date = []
post_author = []
post_category = []
post_comments = []
# post_likes = []
for i in range(len(blog_links)):
    titles.append(blog_links[i].getText())                                           # Store the post title in a list
    link = requests.get(blog_links[i].find('a').get('href'))
    soup = bs4.BeautifulSoup(link.text, from_encoding="utf-8")
    post_date.append(soup.find('time').getText())                                   # Store post date in a list
    post_author.append(soup.find('span', class_='author vcard').getText())            # Store author name in a list
    post_category.append(soup.find('span', class_='cats-links').find('a').getText())  # Store category in a list

    # Find all comments on a blog post and save to a list and if no comments append None
    if soup.find_all('div',{'class':'comment-content'}) != []:
        comments = soup.findAll('div', {'class': 'comment-content'})
        post_comments.append(map(str, (comments[i].getText().strip('\n') for i in range(len(comments)))))

    else:
        post_comments.append('None')

# In[14]:

# Convert the lists into a data frame
df = pd.DataFrame([titles, post_author, post_date, post_category, post_comments]).T

# In[19]:

# Write the data frame to an excel sheet
df.columns=['Post Title', 'Post Author', 'Post Date', 'Post Category', 'Comments']

# In[25]:

df.to_excel('Blog Details.xls', encoding='utf-8', index=False)





