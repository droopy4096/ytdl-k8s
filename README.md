# ytdl-k8s

Youtube Downloader Server Helm chart

Using existing work in https://github.com/nbr23/youtube-dl-server this project wraps deployment for `youtube-dl-server` into convenient Helm chart.

# Sample deployment

```yaml
# Use local NFS storage for downloads:
storage:
  downloads: 
    volume:
      nfs: 
        server: 192.168.1.2
        path: /mnt/Data/youtube

# Setup the ingress to access web interface
ingress:
  enabled: true
  className: ""
  annotations: {}
  hosts:
    - host: ytdl.mydoma.in
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

# Configure 'ytdl' options. We're following mostly the same configuration pattern 
# as youtube-dl-server with some additions/clarifications:
ytdl:
  # File path for playlist items:
  playlist_template: '%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s [%(id)s].%(width)s.%(ext)s'
  # File path for single videos:
  output_template: '%(uploader)s/%(title)s [%(id)s].%(width)s.%(ext)s'
  # ytdl command line options with leading '--' removed:
  options: 
    # Drop quality:
    format: "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    format-sort: "ext:mp4:m4a"

# Optional cleanup job removing empty dirs:
cleanup:
  enabled: true
  schedule: "*/5 * * * *"

# Optional converter job transcoding videos to more suitable format (default vp9->h264):
converter:
  enabled: true
  schedule: "*/5 * * * *"
  # add filename suffix after conversion for easy recognition of converted files (optional):
  suffix: "h264"
```