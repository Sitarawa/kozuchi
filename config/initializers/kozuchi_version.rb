# kozuchi version
# リリースしたら直後に上げること

KOZUCHI_MAJOR_VERSION  = 4
KOZUCHI_MIDDLE_VERSION = 0
KOZUCHI_MINORE_VERSION = 5

KOZUCHI_VERSION = "#{KOZUCHI_MAJOR_VERSION}.#{KOZUCHI_MIDDLE_VERSION}.#{KOZUCHI_MINORE_VERSION}"

# 画面に出すバージョン。本家 (nay/kozuchi) のバージョンに、このフォークの印と動いているソースのリビジョンを添える
# エクスポートには本家と同じ形式の KOZUCHI_VERSION を使う
KOZUCHI_VERSION_POSTFIX = "sitarawa"

# Docker イメージではビルド時に REVISION ファイルへ書き出す（docker/Dockerfile 参照）。なければ git から取る
KOZUCHI_REVISION = begin
  revision_file = Rails.root.join("REVISION")
  if revision_file.exist?
    revision_file.read.strip.presence
  elsif Rails.root.join(".git").exist?
    `git -C #{Rails.root} rev-parse --short HEAD 2>/dev/null`.strip.presence
  end
rescue SystemCallError
  nil
end

KOZUCHI_DISPLAY_VERSION = "#{KOZUCHI_VERSION}-#{KOZUCHI_VERSION_POSTFIX}#{" (#{KOZUCHI_REVISION})" if KOZUCHI_REVISION}"
