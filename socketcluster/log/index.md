# Logx

####Logx
```
	Logx  interface {
		Debug(v ...interface{})
		Debugf(format string, v ...interface{})
		Info(v ...interface{})
		Infof(format string, v ...interface{})
		Warning(v ...interface{})
		Warningf(format string, v ...interface{})
		Error(v ...interface{})
		Errorf(format string, v ...interface{})
	}
```

日志模块也是采用插件方式,目前内置了文件方式和终端方式,文件方式带有按日期轮转分割,支持定期清理历史日志方式磁盘写满.