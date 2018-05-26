# git-repository
A simple git repostory docker.

# 基于Alpine linux制作的一个git仓库镜像

### 生成镜像

<pre>
docker build -t git ./
</pre>

### 创建数据卷

<pre>
docker volume create --name git-data
</pre>

### 创建容器

<pre>
docker create --name git -p 1022:22 -v git-data:/git git
</pre>

### 启动容器

<pre>
docker start git
</pre>

### 创建git仓库

<pre>
docker run --rm -v git-data:/git git -c repostory-name
</pre>

### 添加免密访问公钥(直接输入公钥)

<pre>
docker run --rm -v git-data:/git git -k “public key content”
</pre>

### 添加免密访问公钥(从公钥文件导入)

<pre>
docker run --rm -v git-data:/git -v $PWD/.ssh:/ssh git -f /ssh/id_rsa.pub
</pre>
