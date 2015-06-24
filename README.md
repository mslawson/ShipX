# ShipX

### Setup

bundle exec rake import:dictionaries

### Deployment

bundle exec cap production deploy

Assumes your SSH key is in ~/.ssh/itoi-prod.pem



To rename ERB views to HAML (for gems like devise that won't generate them right):

```
#!bash

for file in app/views/addresses/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done
```



