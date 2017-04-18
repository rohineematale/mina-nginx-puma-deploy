# mina_puma-deploy

Add gems for Gemfile,

```
gem 'mina', group: [:development, :test]
gem 'mina-puma', group: [:development, :test], :require => false
```

Add files to respective rails app folders.

And then,
```
mina setup
mina deploy to=<env>
```

Please find source here [Blog](http://thelazylog.com/deploying-rails-application-with-nginx-puma-and-mina/).