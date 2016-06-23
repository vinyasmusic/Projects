from __future__ import unicode_literals


# Create your models here.
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.db.models import Count


class PostVoteCountManager(models.Manager):
    pass


class Post(models.Model):
    author = models.ForeignKey(User)
    title = models.CharField("Headline",max_length=200)   # Title of the post
    text = models.TextField()
    url = models.URLField("URL", max_length=250, blank = True)
    # created_date = models.DateTimeField( default=timezone.now )
    published_date = models.DateTimeField(
            blank=True, null=True)                     # Creation time of the post
    votes = models.IntegerField(default=0)             # Number of votes

    def publish(self):
        self.published_date = timezone.now()
        self.save()

    def __unicode__(self):
        return self.title
    with_votes = PostVoteCountManager()
    objects = models.Manager()


class Vote(models.Model):
    voter = models.ForeignKey(User)
    post = models.ForeignKey(Post)



class PostVoteCountManager(models.Manager):
    def get_query_set(self):
        return super(PostVoteCountManager, self).get_queryset().annotate(
            votes=Count('vote')).order_by('-votes')


