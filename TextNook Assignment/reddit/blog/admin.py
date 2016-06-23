

# Register your models here.

from django.contrib import admin
from .models import Post, Vote


class PostAdmin(admin.ModelAdmin):
    pass

admin.site.register(Post, PostAdmin)


class VoteAdmin(admin.ModelAdmin):
    pass
admin.site.register(Vote, VoteAdmin)