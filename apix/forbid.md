# 禁用函数名

####Init
```
func (c *Controller) Init(baseController BaseController) 
```
初始化控制器相关操作

####ParseForm
```
func (c *Controller) ParseForm(obj interface{})
```
解析表单

####GetString
```
func (c *Controller) GetString(key string, def ...string) string 
```
获取string类型query参数

####GetStrings
```
func (c *Controller) GetStrings(key string, def ...[]string)
```
获取string[]类型参数,比如表单中checkbox(input[type=checkbox])

####GetInt
```
func (c *Controller) GetInt(key string, def ...int) (int, error)
```
获取int类型参数

####GetInt8
```
func (c *Controller) GetInt8(key string, def ...int8) (int8, error)
```
获取int8类型参数

####GetUint8
```
func (c *Controller) GetUint8(key string, def ...uint8) (uint8, error)
```
获取uint8类型参数

####GetInt16
```
func (c *Controller) GetInt16(key string, def ...int) (int, error)
```
获取int16类型参数

####GetUint16
```
func (c *Controller) GetUint16(key string, def ...uint16) (uint16, error)
```
获取uint16类型参数

####GetInt32
```
func (c *Controller) GetInt32(key string, def ...int32) (int32, error) 
```
获取int32类型参数

####GetUint32
```
func (c *Controller) GetUint32(key string, def ...uint32) (uint32, error)
```
获取uint32类型参数

####GetInt64
```
func (c *Controller) GetInt64(key string, def ...int64) (int64, error)
```
获取int64类型参数

####GetUint64
```
func (c *Controller) GetUint64(key string, def ...uint64) (uint64, error)
```
获取uint64类型参数

####GetFloat
```
func (c *Controller) GetFloat(key string, def ...float64) (float64, error)
```
获取float64类型参数

####GetFile
```
func (c *Controller) GetFile(key string) (multipart.File, *multipart.FileHeader, error)
```
获取file类型参数

####Header
```
func (c *Controller) Header(key string) string
```
获取header

####Cookie
```
func (c *Controller) Cookie(key string) string 
```
获取cookie






