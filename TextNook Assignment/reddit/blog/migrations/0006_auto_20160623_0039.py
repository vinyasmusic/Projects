# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-06-22 19:09
from __future__ import unicode_literals

from django.db import migrations
import django.db.models.manager


class Migration(migrations.Migration):

    dependencies = [
        ('blog', '0005_auto_20160622_0009'),
    ]

    operations = [
        migrations.AlterModelManagers(
            name='post',
            managers=[
                ('with_votes', django.db.models.manager.Manager()),
            ],
        ),
    ]