# 🎬 Nginx RTMP + HLS 实时直播服务

本项目基于 Docker 快速搭建 Nginx-RTMP + HLS 流媒体服务，支持 FFmpeg、OBS 推流，并通过 m3u8 地址播放，适用于直播开发与测试。

---

## 📁 项目结构

```
.
├── Dockerfile            # 构建 Nginx 镜像（含 RTMP 模块）
├── docker-compose.yml    # 启动服务
├── nginx.conf            # RTMP + HLS 配置
└── hls/                  # HLS 切片输出目录（已挂载）
```

---

## 🚀 快速启动

### 构建并运行

```bash
docker-compose up --build
```

成功后：

- RTMP 推流地址：`rtmp://localhost:1935/live/`
- HLS 播放地址：`http://localhost:8800/live/<stream_name>.m3u8`

---

## 📡 推流示例（FFmpeg）

将本地 MP4 推到 RTMP 流：

```bash
ffmpeg -re -i test.mp4 -c copy -f flv rtmp://localhost:1935/live/test
```

使用 OBS 推流配置：

- 流服务器：`rtmp://localhost:1935/live`
- 流名称（Stream key）：`test`

---

## 📺 播放示例

使用支持 HLS 的播放器打开：

```
http://localhost:8800/live/test.m3u8
```

推荐播放方式：

- ✅ Safari 浏览器（原生支持 HLS）
- ✅ VLC 播放器
- ✅ hls.js + HTML5 视频播放器（前端嵌入）

---

## ⚙️ nginx.conf 说明（已内置）

```nginx
rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            hls on;
            hls_path /opt/hls;
            hls_fragment 2s;
            hls_playlist_length 10s;
            hls_continuous on;
            record off;
        }
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {
        listen       8800;
        server_name  localhost;

        location /live/ {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            alias /opt/hls;
            add_header Cache-Control no-cache;
        }

        location / {
            return 200 'RTMP + HLS server is running.';
        }
    }
}
```

---

## 🐳 Docker 常用命令

构建 + 启动服务：

```bash
docker-compose up --build
```

后台运行：

```bash
docker-compose up -d
```

停止服务：

```bash
docker-compose down
```

---

## ❓常见问题

### 为什么 m3u8 会被下载而不是播放？

浏览器默认行为是下载，建议：

- 使用 Safari 浏览器播放
- 使用支持 HLS 的播放器（如 [hls.js](https://github.com/video-dev/hls.js)）
- 用 VLC 或嵌入 HTML 页面

### 停止推流后切片文件消失？

是正常行为。配置中启用了自动删除旧切片（`hls_continuous on` + `hls_flags delete_segments`），目的是节省存储、保持流实时。

---

## 🔧 后续计划

- ✅ 支持自动清理切片
- ✅ Go 项目集成推流接口
- ⏳ 增加 Web 播放控制台
- ⏳ HTTPS 支持与权限控制

---

## 📄 License

MIT License.
