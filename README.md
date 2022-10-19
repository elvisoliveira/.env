# ~/.env
My dot files

```
find . -maxdepth 1 ! -name .git\* -exec sh -c 'ln -s $(pwd)/$0 ~' {} \;
```