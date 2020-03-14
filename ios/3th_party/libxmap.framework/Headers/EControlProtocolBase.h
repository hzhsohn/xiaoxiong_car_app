//
//  EControlProtocolBase.h
//  libxmap_Demo
//
//  Created by Han.zh on 2019/12/11.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

const static char* CTRL_NET_PROTOCOL_VERSION = "v.0.1";

typedef enum _EControlProtocolBase
{
/*
    C代表客户端
    S代表服务器端
    CToS即客户端给服务器端的数据
    SToC服务器返回给客户端的数据
*/
////-------------------------- <解释>                            <参数>
ecpnCToSKeep        =1,             //保活包                         :null
ecpnSToCKeep        =2,             //激活包                         :null
ecpnCToSKeepRtt     =3,             //rtt时间                        :null

////-------------------------- <解释>                            <参数>
ecpuCToSLogin=1000,                 //登录                          :[string 设备品牌型号]
                                    //                              [string 设备唯一标识]
                                    //                              [string group_name]
                                    //                              [string password的MD5]
    
ecpuSToCLogin=1001,                 //                            :[T_GROUP_LOGIN_RESULT(short=1Byte) 结果]
//
//
////-------------------------- <解释>                            <参数>
//
/*
    标准结构
    {
        "cmd":"命令",                 数据类型
        "its": {                     具体参数内容
              ...
          }
    }
*/
ecpuCToSJsonCommand=2000,        //                                :[string json]
ecpuSToCJsonCommand=2001,        //                                :[string json]
//
/*
//------------------------------
//主动接收到的回复
//------------------------------
{"cmd":"invalid_command","its":{"command":string}}//无效指令
{"cmd":"parameter_err","its":{"command":string}}//参数错误
{"cmd":"need_login"}//需要登录操作
{"cmd":"permission_denied","its":{"command":string}}//权限不足

//------------------------------
//不需要权限可执行的操作
//------------------------------
{"cmd":"login_out"}            //退出登录系统
{"cmd":"login_out_rb"}        //退出登录系统回复
{"cmd":"protocol_version"}    //获取当前项目信息
{"cmd":"protocol_version_rb", "its":{"v":string}}
//---------------------------
//管理员权限,管理员权限的指使都用+开头
//------------------------------
{"cmd":"+set_password","its":{"username":string,"password":string}}//修改指定用户的密码
{"cmd":"+set_password_rb","its":{"ret":bool}}

{"cmd":"+set_dpid","its":{"dpid":string}} //设置dpid
{"cmd":"+set_dpid_rb","its":{"ret":bool,"dpid":string}}
{"cmd":"+set_caid","its":{"caid":string}} //设置CAID
{"cmd":"+set_caid_rb","its":{"ret":bool,"caid":string}}

{"cmd":"+set_myname","its":{"name":string}}//修改设备名称
{"cmd":"+set_myname_rb","its":{"ret":bool,"name":string}}

{"cmd":"+add_user","its":{"user":string,"passwd":string,"desc":string,"is_admin":int}}//新增用户
{"cmd":"+add_user_rb","its":{"ret":bool,"user":string,"desc":string,"is_admin":int}}
{"cmd":"+delete_user","its":{"user":string}}    //删除用户
{"cmd":"+delete_user_rb","its":{"status":int , "msg":string , "user":string}}
{"cmd":"+set_admin","its":{"user":string,"is_admin":int}}
{"cmd":"+set_admin_rb","its":{"user":string,"is_admin":int}}

//---------------------------
//普通权限
//------------------------------
{"cmd":"msd/a", "its":{"head":string,"var":string}} //在MSD/A广播里面发送一条信息

{"cmd":"project_info"}//获取当前项目信息
{"cmd":"project_info_rb", "its":{"ret":bool,"create_time":string,"ver":string,"title":string,"desc":string}}

{"cmd":"my_password","its":{"old":string,"new":string}}//修改我的密码
{"cmd":"my_password_rb","its":{"ret":bool}}

{"cmd":"mqtt"} //获取MQTT连接信息
{"cmd":"mqtt_rb", "its":{"cnt":int}}
{"cmd":"mqtt_c","its":{"index":int}}
{"cmd":"mqtt_c_rb", "its":{"index":int,"host":string,"port":int,"connected":bool}}//发送内容,返正-1为不存在记录
{"cmd":"mqtt_connected_rb", "its":{"host":string,"port":int}}
{"cmd":"mqtt_disconnect_rb", "its":{"host":string,"port":int}}

{"cmd":"online_msd"} //获取在线msd设备
{"cmd":"online_msd_rb", "its":{"cnt":int}}
{"cmd":"online_msd_c","its":{"index":int}}
{"cmd":"online_msd_c_rb", "its":{"index":int,"uuid":string,"depend":bool,"info":object}}//发送内容,返正-1为不存在记录
{"cmd":"online_msd_income_rb", "its":{"uuid":string,"depend":bool,"info":object}}
{"cmd":"online_msd_leave_rb", "its":{"uuid":string}}

{"cmd":"user_list"}//获取当前用户列表
{"cmd":"user_list_rb", "its":{"cnt":int}}//发送开始
{"cmd":"user_list_c","its":{"index":int}}
{"cmd":"user_list_c_rb", "its":{"index":int,"user":string,"desc":string,"is_admin":int}}//发送内容,返正-1为不存在记录

{"cmd":"push_group"}//获取当前推送组
{"cmd":"push_group_rb", "its":{"cnt":int}}//发送开始
{"cmd":"push_group_c","its":{"index":int}}//发送完成
{"cmd":"push_group_c_rb", "its":{"index":int,"type":string,"aname":string}}//发送内容,aname是别名.index是-1为不存在记录

{"cmd":"push_group_add","its":{"type":string}}//添加推送组
{"cmd":"push_group_add_rb","its":{"ret":bool,"type":string}}
{"cmd":"push_group_del","its":{"type":string}}//删除推送组
{"cmd":"push_group_del_rb","its":{"ret":bool,"type":string}}
{"cmd":"push_group_aname","its":{"type":string,"aname":string}}//修改别名
{"cmd":"push_group_aname_rb","its":{"ret":bool,"type":string,"aname":string}}

{"cmd":"push_dev","its":{"type":string}}//获取当前推送设备列表
{"cmd":"push_dev_rb", "its":{"cnt":int}}//发送内容,cnt返回-1为不存在记录
{"cmd":"push_dev_c","its":{"index":int}}//发送完成
{"cmd":"push_dev_c_rb", "its":{"index":int,"type":string,"unique_id":string,"dev":string,"token":string,"desc":string}}//发送内容,is_group0是组1是推送设备

{"cmd":"push_dev_add","its":{"type":string,"dev":string,"token":string,"desc":string}}//添加推送对象
{"cmd":"push_dev_add_rb","its":{"ret":bool,"type":string,"unique_id":string,"dev":string,"token":string,"desc":string}}
{"cmd":"push_dev_del","its":{"unique_id":string}}//删除推送对象
{"cmd":"push_dev_del_rb","its":{"ret":bool,"unique_id":string}}
{"cmd":"push_dev_modify","its":{"unique_id":string,"dev":string,"token":string,"desc":string}}//修改推送对象
{"cmd":"push_dev_modify_rb","its":{"ret":bool,"unique_id":string,"type":string,"dev":string,"token":string,"desc":string}}

{"cmd":"dev_label"}//获取devlabel列表,连接过中控的所有msd设备都会被增加到设备标签里
{"cmd":"dev_label_rb", "its":{"cnt":int}}//发送开始
{"cmd":"dev_label_c","its":{"index":int}}//发送完成
{"cmd":"dev_label_c_rb", "its":{"index":int,"unique_id":string,"devname":string,"label":string,"desc":string}}//发送内容
{"cmd":"dev_label_add", "its":{"devname":string,"label":string,"desc":string}}//添加标签
{"cmd":"dev_label_add_rb", "its":{"ret":bool,"unique_id":string,"devname":string,"label":string,"desc":string}}
{"cmd":"dev_label_del", "its":{"unique_id":string}}//删除标签
{"cmd":"dev_label_del_rb", "its":{"ret":bool,"unique_id":string}}
{"cmd":"dev_label_modify", "its":{"unique_id":string,"devname":string,"label":string,"desc":string}}//修改标签
{"cmd":"dev_label_modify_rb", "its":{"ret":bool,"unique_id":string,"devname":string,"label":string,"desc":string}}//修改标签

{"cmd":"wall_list"}//获取当前wall列表
{"cmd":"wall_list_rb", "its":{"cnt":int}}//发送开始
{"cmd":"wall_list_c","its":{"index":int}}//发送完成
{"cmd":"wall_list_c_rb", "its":{"index":int,"file":string,"label":string,"desc":string}}//发送内容
{"cmd":"wall_element", "its":{"file":string}}
{"cmd":"wall_element_rb", "its":{"file":string ,"label":string ,"desc":string , "cnt":int}} //如果文件不存在cnt为-1
{"cmd":"wall_element_c","its":{"file":string ,"index":int}}
{"cmd":"wall_element_c_rb", "its":{"file":string,"index":int,"type":string,"name":string,其它控件属性}}//内容
{"cmd":"box","its": {"file":string ,"name":string}}//控制场景的指令
{"cmd":"box_rb","its": {"file":string,"name":string,"ret":bool}//场景被执行

{"cmd":"msd_udata","its":{"devname":string,"cmd":string,"param":string}}//与MSD脚本交互
{"cmd":"msd_udata_rb","its":{"devflag":string,"devname":string,"cmd":string,"param":string}} //回复MSD设备的状态 obj为LUA插件生成的状态

{"cmd":"msd_ctl_scene","its":{"devname":string,"scene":string,"param":string}//执行场景,param可选参数,场景名称由LUA插件生成
{"cmd":"msd_ctl_scene_rb","its":{"ret":bool,"devflag":string,"devname":string,"scene":string}//执行场景的回复,场景名称由LUA插件生成

*/

//------------------------------
//无登录操作指令
//------------------------------
ecpuCToSNoLoginStringCommand=2002,      //一次性操作临时用户    :[string 执行ID]
                                        //                    [string 用户名]
                                        //                    [unsigned short 数据内容长度]
                                        //                    [binary 通过AES256加密的字符串内容]
ecpuSToCNoLoginStringCommand=2003,      //                  :[string 执行ID][bool 是否加入指令成功]
/*
msd:<设备名>:<场景名>                     例如:msd:3813:scene_close
cup:<wall文件名>:<box场景名>             例如:box:wall.config:cup666
*/

}EControlProtocolBase;



/*///------------------------------------------------------
 *
 *    控制类网络传输的参数属性
 *
 /*///------------------------------------------------------

typedef enum _EControlProtocolResult{
    ecpRetLoginNone                =0,        //未登录或者未登录就即执行操作
    ecpRetLoginSuccess            =1,        //登录成功
    ecpRetLoginPasswordFail        =2,        //密码错误
    ecpRetLoginOverload            =3,        //服务器超载,会断开通讯连接
    ecpRetLoginRemoveOccup        =4        //断开已经在线的设备设备,会断开通讯连接
}EControlProtocolResult;
