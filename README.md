## todo list
简单的任务清单插件，可以快速在本地创建todo，不用再打开其他笔记软件什么的，用来做开发中的tips记录倒也是不错的。

### todo 详解
目前所有数据都是以json文件形式存储于本地，每次打开Todo都会读取数据文件加载到buf中，json文件内容大致如下
```json
[
    {
        "is_deleted": false,
        "title": "支持编辑模块",
        "labels": [
            "gre_circle"
        ],
        "module": "TODO",
        "status": "checked",
        "id": "uv_83122059934640_72896"
    }
]
```
#### 字段释义


| 字段名 | 字段说明 | 备注 |
|:-------|:-------:|-------:|
| id  | 唯一ID   |   |
| title  | 任务主题   | 列表显示的内容  |
| module  | 任务模块   | []内显示的内容  |
| content  | 任务详情   | 预览显示的内容  |
| status | 状态标志  | 状态unicode key  |
| labels | 标签数组   | 自定义unicode key  |
| is_deleted | 删除标志   | 软删除标记  |


### Keymap

| 按键 | 描述 |
|:-------|:-------:|
| i  | 在最后一行插入   |
| o  | 在当前行后插入   |
| O  | 在当前行前插入   |
| w  | 保存    |
| r  | 重新加载   |
| ds  | 标记删除(Toggle)  |
| dd  | 数据删除   |
| ct  | 编辑任务   |
| cm  | 编辑模块   |
| ms  | 标记状态   |
| ml  | 标记标签   |
| u  | 撤回修改   |
| p  | 预览内容(Toggle)   |


### RoadMap
1. 完善配置模块
2. 完善任务详情的编辑和预览
3. 完善status/labels的编辑
4. 部分keymap的优化 如: 撤销、跳转

