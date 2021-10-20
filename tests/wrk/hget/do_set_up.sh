cd /tmp
yum groupinstall 'Development Tools' -y
yum install -y openssl-devel git -y
git clone https://gitee.com/mirrors/wrk.git wrk
cd wrk
make
cp wrk /usr/local/bin/
cd /tmp
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh -b
/root/miniconda3/bin/conda install redis-py
cd /opt/winterfell_others/wrk/hget
/root/miniconda3/bin/python hset_redis.py

