from django.shortcuts import render
from django.views.generic import ListView
from models import Post , Vote
from django.views.generic.edit import CreateView
from .forms import PostForm
# Create your views here.


class PostListView(ListView):
    model = Post
    queryset = Post.with_votes.all()
    paginate_by = 3


class PostCreateView(CreateView):
    model = Post
    form_class = PostForm

    def form_valid(self, form):
        f = form.save(commit=False)
        f.votes = 0
        f.author = self.request.user
        f.save()

        return super(CreateView, self).form_valid(form)

"""def post_new(request):

    form = PostForm()
    return render(request, 'blog/post_edit.html', {'form': form})

"""

