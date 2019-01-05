# 检测域名证书过期并重新申请

[![Build Status](https://travis-ci.org/Haujilo/renew_cert.svg?branch=master)](https://travis-ci.org/Haujilo/renew_cert)

## 流程

1. 判断证书是否需要重新生成，如果不需要则直接退出
2. 安装acme.sh
3. 使用acme.sh利用DNS模式重新生成证书
4. 把证书打包成zip
5. 把证书推送到使用的托管服务（netlify）和CDN(腾讯云)
6. 把打包生成的证书zip发送到自己的安全邮箱
