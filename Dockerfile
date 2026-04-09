FROM ruby:3.3.6-slim

# 必要なシステムパッケージをインストール
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    libvips \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリ
WORKDIR /app

# Gemfile を先にコピーして bundle install（キャッシュ効率化）
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4

# アプリケーションコードをコピー
COPY . .

# アプリケーションに必要なディレクトリを作成
RUN mkdir -p tmp/pids

# アセットプリコンパイル（本番用CSS/JSを生成）
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Cloud Run はポート 8080 を使用
EXPOSE 8080

# Puma サーバーで起動
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
