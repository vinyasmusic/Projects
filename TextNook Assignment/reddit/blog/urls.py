from django.conf.urls import url
from . import views
from blog.views import PostListView
urlpatterns = [
    #url(r'^$', views.post_list, name='post_list'),
    url(r'^$',PostListView.as_view())
    #url(r'^post/new/$', views.post_new, name='post_new'),
]

