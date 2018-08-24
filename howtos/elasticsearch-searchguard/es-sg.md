# Установка elasticsearch + search-guard

## Пакеты

```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-get update
apt install openjdk-8-jdk
apt-get install elasticsearch
```

## search-guard
Идём сюда https://search.maven.org/search?q=g:com.floragunn%20AND%20a:search-guard-6

Качаем zip

Кладём в /root/dist

Ставим

/usr/share/elasticsearch/bin/elasticsearch-plugin install -b file:///root/dist/search-guard-6-6.3.2-23.0.zip
