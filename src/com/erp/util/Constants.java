package com.erp.util;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.apache.struts2.ServletActionContext;

import com.erp.model.SysActionLog;
import com.erp.shiro.ShiroUser;

/**
* 类功能说明 TODO:常用常量定义
* 类修改者
* 修改日期
* 修改说明
* <p>Title: Constants.java</p>
* <p>Description:杰斯科技</p>
* <p>Copyright: Copyright (c) 2006</p>
* <p>Company:杰斯科技有限公司</p>
* @author hujc 631410114@qq.com
* @date 2013-5-7 下午2:50:52
* @version V1.0
*/

public class Constants
{
	public static String APP_REPORT_TITLE = "嘉兴一卡通平台";//报表标题
	public static String APP_DES3_DEFAULT = "erp2erp2";//3des 加密默认密钥值
	public static String APP_REPORT_TYPE_PDF = "0";//报表类型 pdf类型
	public static String APP_REPORT_TYPE_HTML = "1";//报表类型html类型
	public static String APP_REPORT_TYPE_PDF2 = "2";//报表类型pdf实体文件	
	public static String DEFAULT_CODE="0000";//固定缺省代码，修改此值时需要同时修改cardservice.js中顶部对应的变量
	public static String INDUS_CODE="0000";//应用代码，修改此值时需要同时修改cardservice.js中顶部对应的变量
	public static String CARD_VERSION="1.00";//卡版本号
	public static String USED_FLAG="01";//生成任务时启用标志00未启用 01-公共钱包应用已使用 02-月票钱包应用已使用 03-公共钱包应用和月票钱包应用均已启用
	public static String BURSEBALANCE="0000000000";//公共钱包金额（如果存到，长度为10，单位到分，右靠齐，不足前补0）
	public static String MONTHBALANCE="0000000000";//月票钱包金额（如果存到，长度为10，单位到分，右靠齐，不足前补0）
	public static String INIT_ORG_ID = "91560000023304003304002A";
	public static String APPLY_TYPE_CCSL = "0";  //申领类型_初次申领
	public static String APPLY_TYPE_HK = "1";  //申领类型_换卡
	public static String APPLY_TYPE_BK = "2";  //申领类型_补卡
	public static String BUS_USE_FLAG_QB="01";//公用钱包应用已启用
	public static String URGENT_BD="0";//本地制卡
	public static String URGENT_WB="1";//外包制卡
	public static String URGENT_BDJJ="2";//本地加急
	public static String URGENT_WBJJ="3";//外包加急
	public static String MAKE_TYPE_XCZK = "0";  //制卡方式_现场发卡
	public static String MAKE_TYPE_HXZK = "1";  //制卡方式_后续制卡
	public static String NEWLINE="\r\n";//文件换行
	public static String APP_SHOW_BANK_MSG = "0";//应用是否显示银行信息
	public static String APP_SHOW_SB_MSG = "0";//应用是否显示社保信息
	public static String ENTER_TO_QUERY = "0";
	//操作员身份级别
	public static final Integer SYS_OPERATOR_LEVEL_COMMON = 0;//普通柜员数据权限
	public static final Integer SYS_OPERATOR_LEVEL_BRANCH = 1;//网点主管数据权限
	public static final Integer SYS_OPERATOR_LEVEL_BRANCHALL = 2;//网点和子网点数据权限
	public static final Integer SYS_OPERATOR_LEVEL_ORGAN = 3;//机构权限
	public static final Integer SYS_OPERATOR_LEVEL_ORGANALL = 4;//机构和子结构数据权限
	public static final Integer SYS_OPERATOR_LEVEL_ADMIN = 9;//所有权限
	
	public static final String LOGIN_SESSION_DATANAME="users";
	public static final String LOGIN_SESSION_SYSBRANCH="sysBranch";
	public static final String LOGIN_URL="login";
	public static final String LOGOUT_URL="logout";
	public static final String LOGIN_SUCCESS_URL="index";
	public static final String LOGIN_LOGIN_OUT_URL="loginout";
	public static final String LOGIN_MSG="loginMsg";
	public static final String USERNAME_IS_NULL="用户名为空!";
	public static final String LOGIN_IS_EXIST="该用户已登录!";
	public static final String UNKNOWN_SESSION_EXCEPTION="异常会话!";
	public static final String UNKNOWN_ACCOUNT_EXCEPTION="用户名或密码不正确！";
	public static final String INCORRECT_CREDENTIALS_EXCEPTION="用户名或密码不正确！";
	public static final String DAY_BAL_IS_EXECUTE_EXCEPTION = "当天已轧账，不能再次登陆！";
	public static final String LOCKED_ACCOUNT_EXCEPTION="账号已被锁定，请与系统管理员联系!";
	public static final String INCORRECT_CAPTCHA_EXCEPTION= "验证码错误!";
	public static final String AUTHENTICATION_EXCEPTION= "您没有授权!";
	public static final String PASSWORD_EXPIRATION="密码过期，请与系统管理员联系!";
	public static final String UNKNOWN_EXCEPTION= "出现未知异常,请与系统管理员联系!";
	public static final String TREE_GRID_ADD_STATUS= "add";
	public static final String POST_DATA_SUCCESS= "数据更新成功!";
	public static final String POST_DATA_FAIL= "提交失败了!";
	public static final String GET_SQL_LIKE= "%";
	public static final String GET_SQL_EQ= "'";
	public static final String IS_FUNCTION= "F";
	public static final String PERSISTENCE_STATUS= "A";
	public static final String PERSISTENCE_DELETE_STATUS= "I";
	public static final String SYSTEM_hujc= "admin";
	public static final String NULL_STRING= "";
	public static final String IS_DOT= ".";
	public static final String HQL_LIKE= "like";
	public static final String TEXT_TYPE_PLAIN= "text/plain";
	public static final String TEXT_TYPE_HTML= "text/html";
	public static final String FUNCTION_TYPE_O= "O";
	public static final String TREE_STATUS_OPEN= "open";
	public static final String TREE_STATUS_CLOSED= "closed";
	public static final String IS_EXT_SUBMENU= " 可能包含菜单或该网点下存在柜员不能注销！";
	public static final String SHIRO_USER= "shiroUser";
	public static final String ACTIONLOG= "shiroActionLog";
	public static final String LOGS_INSERT= "insert:";
	public static final String LOGS_INSERT_TEXT= "插入:";
	public static final String LOGS_INSERT_NAME= "insertLogs";
	public static final String LOGS_UPDATE= "update:";
	public static final String LOGS_UPDATE_TEXT= "更新:";
	public static final String LOGS_UPDATE_NAME= "updateLogs";
	public static final String LOGS_DELETE= "delete:";
	public static final String LOGS_DELETE_TEXT= "删除:";
	public static final String LOGS_DELETE_NAME= "deleteLogs";
	public static final String LOGS_TB_NAME= "Log";
	public static final String FILE_SUFFIX_SQL= ".sql";
	public static final String FILE_SUFFIX_ZIP= ".zip";
	public static final String COIN_TYPE = "1";  //人民币
	
	//卡状态
	public static String CARD_STATE_WQY = "0";  //卡状态_未启用
	public static String CARD_STATE_ZC = "1";  //卡状态_正常
	public static String CARD_STATE_GS = "3";  //卡状态_挂失
	public static String CARD_STATE_SD = "4";  //卡状态_锁定
	public static String CARD_STATE_ZF = "7";  //卡状态_作废
	public static String CARD_STATE_YGS = "2";  //卡状态_预挂失
	public static String CARD_STATE_ZX = "9";  //卡状态_注销
	/**卡账户状态,1正常状态*/
	public static String ACC_STATE_WQY = "0";
	public static String ACC_STATE_ZC = "1";
	/**卡账户状态,2预挂失状态*/
	public static String ACC_STATE_YGS = "2";
	/**卡账户状态,3挂失状态*/
	public static String ACC_STATE_GS = "3";
	public static String ACC_STATE_SD = "4";
	/**卡账户状态,9注销状态*/
	public static String ACC_STATE_ZX = "9";
	//账户类型
	public static String ACC_KIND_PTZH="00";//普通账户
	public static String ACC_KIND_QBZH="01";//钱包账户-脱机账户，电子钱包,小钱包
	public static String ACC_KIND_ZJZH="02";//资金账户,联机账户，大钱包，线上账户
	public static String ACC_KIND_JFZH="03";//积分账户
	public static String ACC_KIND_CZKZH="07";//充值卡账户
	public static String ACC_KIND_WQCZH="09";//未圈存账户
	public static String ACC_KIND_YJZH="10";//押金账户
	//账户类型名称
	public static String ACC_KIND_NAME_QB = "市民卡钱包";
	public static String ACC_KIND_NAME_LJ = "市民卡账户";
	
	public static String ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD="0";//充值(加)
	public static String ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB="1";//消费(减)
	
	//证件类型
	public static String CERT_TYPE_SFZ = "1";  //证件类型_身份证
	public static String CERT_TYPE_HKB = "2";  //证件类型_户口簿
	public static String CERT_TYPE_JGZ = "3";  //证件类型_军官证
	public static String CERT_TYPE_HZ = "4";  //证件类型_护照
	public static String CERT_TYPE_HJZM = "5";  //证件类型_户籍证明
	public static String CERT_TYPE_QT = "6";  //证件类型_其他
	
	//业务状态
	public static String STATE_ZC = "0";  //状态_正常
	public static String STATE_ZX = "1";  //状态_注销
	
	public static String YES_NO_YES = "0";  //是否_是
	public static String YES_NO_NO = "1";  //是否_否
	
	public static String TR_STATE_ZC="0";//正常
	public static String TR_STATE_CX="1";//撤销
	public static String TR_STATE_CZ="2";//冲正
	public static String TR_STATE_TH="3";//退货
	public static String TR_STATE_HJL="9";//灰记录
	//挂失标志
	public static String LSS_FLAG_ZC = "0";  //挂失标志_正常
	public static String LSS_FLAG_KTGS = "1";  //挂失标志_口头挂失
	public static String LSS_FLAG_SMGS = "2";  //挂失标志_书面挂失
	//黑名单类型
	public static String BLK_TYPE_SW = "01";  //黑名单类型_死亡
	public static String BLK_TYPE_GS = "02";  //黑名单类型_挂失
	public static String BLK_TYPE_KTGS = "03";  //黑名单类型_口头挂失
	public static String BLK_TYPE_YYSD = "04";  //黑名单类型_应用锁定
	public static String BLK_TYPE_YYJS = "05";  //黑名单类型_应用解锁
	public static String BLK_TYPE_CA = "06";  //黑名单类型_CA证书
	public static String BLK_TYPE_ZX = "99";  //黑名单类型_注销
	/**CARD_BLACK 黑名单状态 0 正常*/
	public static String BLK_STATE_YX = "0";
	/**CARD_BLACK 黑名单状态 1 无效*/
	public static String BLK_STATE_WX = "1";
	//卡类型
	public static String CARD_TYPE_LIST = "120,100";//卡类型默认显示列表
	public static String CARD_TYPE_QGN = "100";  //卡类别_全功能卡
	public static String CARD_TYPE_SMZK = "120";//卡类别_金融市民卡
	public static String CARD_TYPE_JMK = "210";  //卡类别_C卡
	public static String CARD_TYPE_YCT = "220";  //卡类别_城市通
	public static String CARD_TYPE_SERVANT = "230";//公务员卡
	public static String CARD_TYPE_STAFF = "240";//员工卡
	public static String CARD_TYPE_ADMIN = "241";//管理卡
	public static String CARD_TYPE_TEST = "242";//测试卡
	public static String CARD_TYPE_FJMK = "310";//卡类别_单芯片卡_普通卡
	public static String CARD_TYPE_FJMK_XS = "311";//卡类别_单芯片卡_学生卡
	public static String CARD_TYPE_JNK = "321";//卡类别_非记名畅通卡
	public static String CARD_TYPE_JMK_BCP = "390";  //半成品卡
	public static String CARD_TYPE_CZK = "810"; //100元充值卡
	public static String CARD_TYPE_CZ0 = "800";  //卡类别_无面额账户卡
	public static String CARD_TYPE_CZ50 = "805";  //卡类别_面额50账户卡
	public static String CARD_TYPE_CZ100 = "811";  //卡类别_面额100账户卡
	public static String CARD_TYPE_CZ200 = "812";  //卡类别_面额200账户卡
	public static String CARD_TYPE_CZ300 = "813";  //卡类别_面额300账户卡
	public static String CARD_TYPE_CZ500 = "815";  //卡类别_面额500账户卡
	public static String CARD_TYPE_CZ1000 = "821";  //卡类别_面额1000账户卡
	public static String CARD_TYPE_CZ2000 = "822";  //卡类别_面额2000账户卡
	public static String CARD_TYPE_CZ5000 = "825";  //卡类别_面额5000账户卡
	public static String CARD_TYPE_CZ10000 = "831";  //卡类别_面额10000账户卡
	
	public static String CARD_TYPE_CATALOG1 = "1";  //卡类别_卡种类，1全功能，2记名个性，3记名非个性，5非记名，8充值卡
	public static String CARD_TYPE_CATALOG2 = "2";  //卡类别_卡种类，1全功能，2记名个性，3记名非个性，5非记名，8充值卡
	public static String CARD_TYPE_CATALOG3 = "3";  //卡类别_卡种类，1全功能，2记名个性，3记名非个性，5非记名，8充值卡
	public static String CARD_TYPE_CATALOG5 = "5";  //卡类别_卡种类，1全功能，2记名个性，3记名非个性，5非记名，8充值卡
	public static String CARD_TYPE_CATALOG8 = "8";  //卡类别_卡种类，1全功能，2记名个性，3记名非个性，5非记名，8充值卡
	
	//任务来源
	public static String TASK_SRC_LXSLHZ = "0";  //任务来源_零星申领汇总
	public static String TASK_SRC_GMSL = "1";  //任务来源_规模申领
	public static String TASK_SRC_FGXHCG = "2";  //任务来源_非个性化采购任务
	public static String TASK_SRC_SBSL = "3";//任务来源_社保申领
	public static String TASK_SRC_DRSL = "4";  //任务来源_导入申领
	
	
	
	//业务受理类型
	public static final String ACPT_TYPE_SH = "0";
	public static final String ACPT_TYPE_GM = "1";
	public static final String ACPT_TYPE_DL = "2";
	public static final String ACPT_TYPE_ZZ = "3";
	public static final String ACPT_TYPE_DH = "4";
	public static final String ACPT_TYPE_WZ = "5";//+"'',");//ACPT_TYPE	CHAR(1)	Y 受理点类型(1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
	public static final String ACPT_TYPE_SC = "6";
	
	
	public static final String MAIN_TYPE_WD = "0";//网点
	public static final String MAIN_TYPE_CARD = "1";//个人/卡
	public static final String MAIN_TYPE_DW = "2";//单位
	public static final String MAIN_TYPE_SH = "3";//商户
	public static final String MAIN_TYPE_YYJG = "4";//运营机构
	public static final String MAIN_TYPE_HZJG = "5";//合作机构

	
	//申领状态
	public static final String APPLY_STATE_YSQ = "00";//已申领
	public static final String APPLY_STATE_RWYSC = "10";//任务已生成
	public static final String APPLY_STATE_YFWJW = "11";//已发卫计委
	public static final String APPLY_STATE_WJWSHBTG = "12";//卫计委审核不通过
	public static final String APPLY_STATE_WJWSHTG = "13";//卫计委审核已通过
	public static final String APPLY_STATE_YFBANK = "14";//已发银行
	public static final String APPLY_STATE_YHSHBTG = "15";//银行审核不通过
	public static final String APPLY_STATE_YHSHTG = "16";//银行审核通过
	public static final String APPLY_STATE_YFST = "17";//已发省厅
	public static final String APPLY_STATE_STSHBTG = "18";//省厅审核不通过
	public static final String APPLY_STATE_STSHTG = "19";//省厅审核通过
	public static final String APPLY_STATE_ZKZ = "20";//制卡中
	public static final String APPLY_STATE_YZK = "30";//已制卡
	public static final String APPLY_STATE_YHKHZ = "31";//银行开户中
	public static final String APPLY_STATE_YHKHSB = "32";//银行开户失败
	public static final String APPLY_STATE_YHKHCG = "33";//银行开户成功
	public static final String APPLY_STATE_YPS = "40";//已配送
	public static final String APPLY_STATE_YJS = "50";//已接收
	public static final String APPLY_STATE_YFF = "60";//已发放
	public static final String APPLY_STATE_YTK = "70";//已退卡
	public static final String APPLY_STATE_YHS = "80";//已回收
	public static final String APPLY_STATE_YZX = "90";//已注销
	
	public static final String APPLY_WAY_LX = "0";//零星申领
	public static final String APPLY_WAY_DW = "1";//单位申领
	public static final String APPLY_WAY_SQ = "2";//社区申领
	public static final String APPLY_WAY_XX = "3";//学校申领;
	
	// 充值卡状态
	public static final String CARD_RECHARGE_STATE_WSY = "0"; //未使用
	public static final String CARD_RECHARGE_STATE_WJH = "1"; //未激活
	public static final String CARD_RECHARGE_STATE_YJH = "2"; //已激活
	public static final String CARD_RECHARGE_STATE_YSY = "3"; //已使用
	public static final String CARD_RECHARGE_STATE_YZX = "9"; //已注销
	
	//任务状态
	public static final String TASK_STATE_LIST = "00,03,04,10,20,30,40,50,90";
	public static final String TASK_STATE_YSC = "00";//任务已生成
	public static final String TASK_STATE_YFWJW = "01";//已发卫计委
	public static final String TASK_STATE_WJWYSH = "02";//卫计委已审核
	public static final String TASK_STATE_YFYH = "03";//已发银行
	public static final String TASK_STATE_YHYSH = "04";//银行已审核
	public static final String TASK_STATE_YFST = "05";//已发省厅
	public static final String TASK_STATE_STYSH = "06";//省厅已审核
	public static final String TASK_STATE_STSHZ = "07";//省厅审核过程中
	public static final String TASK_STATE_ZKZ = "10";//制卡中
	public static final String TASK_STATE_YZK = "20";//已制卡
	public static final String TASK_STATE_YHKHZ = "21";//银行开户中
	public static final String TASK_STATE_YHYKH = "22";//银行已开户
	public static final String TASK_STATE_YPS = "30";//已配送
	public static final String TASK_STATE_YJS = "40";//已接收
	public static final String TASK_STATE_FFZ = "50";//发卡中
	public static final String TASK_STATE_FFWC = "90";//发放完成
	
	// 卡片回收状态
	public static final String RECOVER_STATUS_YHS = "0"; // 已回收
	public static final String RECOVER_STATUS_YFF = "1"; // 已发放

	//社保申领状态
	public static final String CARD_APPLY_SB_STATE_DSL = "00";//待申领
	public static final String CARD_APPLY_SB_STATE_YCX = "01";//已撤销
	public static final String CARD_APPLY_SB_STATE_YSL = "02";//已申领
	public static final String CARD_APPLY_SB_STATE_YJJ = "03";//已拒绝
	
	public static final class SALE_STATE{
		public static final String WXS = "01";//01 未销售
		public static final String YXS = "02";//02 已销售
	}
	

	////////////////////gecc---20150815/////////////////
	public static String CHG_CARD_REASON_ZLWT = "01";  //换卡原因_质量问题
	public static String CHG_CARD_REASON_SH = "02";  //换卡原因_损坏
	public static String CHG_CARD_REASON_KMXXXG = "03";  //换卡原因_卡面信息更改
	public static String CHG_CARD_REASON_GGYH = "04";  //换卡原因_更改银行
	public static String CHG_CARD_REASON_YXQM = "05";  //换卡原因_有效期满
	public static String CHG_CARD_REASON_QT = "99";  //换卡原因_其他
	
	public static String CANCEL_REASON_SWTK = "0";  //注销原因_死亡退卡
	public static String CANCEL_REASON_SHTK = "1";  //注销原因_损坏退卡
	public static String CANCEL_REASON_ZLTK = "2";  //注销原因_质量退卡
	public static String CANCEL_REASON_DSTK = "3";  //注销原因_丢失补卡
	public static String CANCEL_REASON_HK = "4";  //注销原因_换卡
	public static String CANCEL_REASON_SBZYTK = "5"; //注销原因_社保转移退卡
	public static String CANCEL_REASON_QT = "6"; //注销原因_其他
	
	
	
	public static String TASK_WAY_WD = "0";  //任务组织方式_网点
	public static String TASK_WAY_DW = "1";  //任务组织方式_单位
	public static String TASK_WAY_SQ = "2";  //任务组织方式_社区
	public static String TASK_WAY_XX = "3";  //任务组织方式_学校
	public static String TASK_WAY_DR = "4";  //任务组织方式_导入
	
	public static String GOODS_STATE_ZC = "0";  //物品状态_正常
	public static String GOODS_STATE_HSDCL = "1";  //物品状态_回收卡待处理
	public static String GOODS_STATE_ZLTKDCL = "2";  //物品状态_质量问题退回卡待处理
	public static String GOODS_STATE_WFFFDCL = "3";  //物品状态_无法发放注销卡待处理
	public static String GOODS_STATE_BF = "9";  //物品状态_报废
	public static String INV_TYPE_KGSFP = "1";  //发票种类_卡公司发票
	public static String INV_TYPE_SHFP = "2";  //发票种类_商户发票
	public static String IN_OUT_SR = "0";  //收支标志_收
	public static String IN_OUT_ZC = "1";  //收支标志_支
	public static String IN_OUT_FLAG_W = "0";  //收付标志_无
	public static String IN_OUT_FLAG_SR = "1";  //收付标志_收
	public static String IN_OUT_FLAG_FC = "2";  //收付标志_付
	public static String IN_OUT_FLAG_SF = "3";  //收付标志_收付
	public static String BOOK_STATE_ZS = "0";  //记录状态_正常
	public static String BOOK_STATE_CX = "1";  //记录状态_撤销
	public static String BOOK_STATE_CZ = "2";  //记录状态_冲正
	public static String BOOK_STATE_TH = "3";  //记录状态_退货
	public static String BOOK_STATE_HJL = "9";  //记录状态_灰记录
	
	public static String STK_DELIVERY_WAY_TASK = "1";//库存配送方式 - 按任务配送
	public static String STK_DELIVERY_WAY_INTERVAL = "2";//库存配送方式-按号段配送
	public static String STK_SEND_STATE_YES = "0";  //配送状态-已确认
	public static String STK_SEND_STATE_NO = "1";  //配送状态-未确认
	public static String STK_SEND_STATE_RET = "2";  //配送状态-已退库
	public static String OWN_TYPE_GY = "0";  //归属类型_柜员
	public static String OWN_TYPE_KH = "1";  //归属类型_客户
	

	public static String MAKE_WAY_WB = "1";  //制卡执行方式_外包
	public static String MAKE_WAY_BD = "2";  //制卡执行方式_本地
	
	public static String USER_TYPE_OPERATOR="0";//用户类型_柜员
	public static String USER_TYPE_TERM="1";//用户类型_终端
	
	
	public static String SND_FLAG_BS="0";//不送
	public static String SND_FLAG_DS="1";//待送
	public static String SND_FLAG_ZZS="2";//正在送
	public static String SND_FLAG_YSD="3";//已送达
	
	public static String VRY_FLAG_BP="0";//不批
	public static String VRY_FLAG_DP="1";//待批
	public static String VRY_FLAG_YP="2";//已批
	
	public static String DRW_FLAG_WQ="0";//未取
	public static String DRW_FLAG_YQ="1";//已取
	public static String PAY_FLAG_WF = "0";  //付款标志_未付
	public static String PAY_FLAG_YFZPWQR = "1";  //付款标志_已付支票未确认
	public static String PAY_FLAG_YZF = "2";  //付款标志_已支付
	public static String PAY_WAY_XJ = "1";  //支付方式_现金
	public static String PAY_WAY_HK = "2";  //支付方式_汇款
	public static String PAY_WAY_ZP = "3";  //支付方式_支票
	public static String PAY_WAY_SZ = "4";  //支付方式_赊账
	
	public static String CORP_STATE_ZC = "0";// 单位状态-正常
	public static String CORP_STATE_ZX = "1";// 单位状态-注销

	
	//短信相关参数
	public static String SMS_STATE_WFS = "0";//未发送
	public static String SMS_STATE_YFS = "1";//已发送
	public static String SMS_STATE_CG = "2";//成功
	public static String SMS_STATE_SB = "3";//失败
	
	//短信类型
	public static String SMS_TYPE_FF = "01";//发放
	public static String SMS_TYPE_CZ = "02";//充值
	public static String SMS_TYPE_XF = "03";//消费
	public static String SMS_TYPE_QC = "04";//圈存
	public static String SMS_TYPE_MMWH = "05";//密码服务
	public static String SMS_TYPE_KFW = "06";//卡服务
	public static String SMS_TYPE_ZDY = "99";//自定义
	//账户科目
	/**联机账户科目*/
	public static final String ACC_ITEM_101101 = "101101";
	
	public static final String ACC_ITEM_201101= "201101";
	/**机构往来款科目账户*/
	public static final String ACC_ITEM_102100 = "102100";
	
	public static final String ACC_ITEM_201104 = "201104";
	
	// 车改批量充值状态 yueh
	/**待确认(审核)*/
	public static final String PAY_CAR_TOTAL_STATE_UNCHECKED = "0";// 待确认(审核)
	/**审核不通过*/
	public static final String PAY_CAR_TOTAL_STATE_CHECK_FAILED = "1";// 审核不通过
	/**已确认*/
	public static final String PAY_CAR_TOTAL_STATE_CHECKED = "2";// 已确认
	/**充值失败*/
	public static final String PAY_CAR_TOTAL_STATE_RECHARGE_FAILED = "3";// 充值失败
	/**部分充值*/
	public static final String PAY_CAR_TOTAL_STATE_PART_RECHARGE = "4";// 部分充值
	/**已充值*/
	public static final String PAY_CAR_TOTAL_STATE_RECHARGE = "5";// 已充值

	// 车改批量充值明细状态 yueh
	/** 待确认(审核) */
	public static final String PAY_CARREFOEM_STATE_UNCHECKED = "0";// 待确认(审核)
	/** 审核不通过*/
	public static final String PAY_CARREFOEM_STATE_CHECK_FAILED = "1";// 审核不通过
	/** 已确认 */
	public static final String PAY_CARREFOEM_STATE_CHECKED = "2";// 已确认
	/** 充值失败 */
	public static final String PAY_CARREFOEM_STATE_RECHARGE_FAILED = "3";// 充值失败
	/** 已充值 */
	public static final String PAY_CARREFOEM_STATE_RECHARGE = "5";// 已充值
	/** 已补充值 */
	public static final String PAY_CARREFOEM_STATE_REDO_RECHARGE = "6";// 已补充值
	
	/** 未绑定 */
	public static final String CARD_BIND_BANKCARD_STATE_UNBIND = "0";//
	/** 已绑定未开通圈存 */
	public static final String CARD_BIND_BANKCARD_STATE_BIND = "1";//
	/** 自主圈存 */
	public static final String CARD_BIND_BANKCARD_STATE_BIND_AND_ZZQC = "2";//
	/** 自主圈存 + 实时圈存 */
	public static final String CARD_BIND_BANKCARD_STATE_BIND_AND_ZZQC_AND_SSQC = "3";//
	
	// 网点类型
	/** 自有网点 */
	public static final Object BRANCH_TYPE_ZY = "1";
	/** 自助网点 */
	public static final Object BRANCH_TYPE_ZZ = "2";
	/** 代理网点 */
	public static final Object BRANCH_TYPE_DL = "3";
	
	//互联互通商户
	
	public static final String SHANGHAI_BIZID = "100102100101043";//上海互联互通结算商户
	public static final String QUANGUO_BIZID = "100102100101042";//全国互联互通结算商户
	
	public static final String CORG_CHECK_OLD_ID = "'100101100100893','330402012003001'";//电信和翼支付合作机构
	/**  
	* 函数功能说明 TODO:获取UUID生成的主键
	* hujc修改者名字
	* 2013-5-8修改日期
	* 修改内容
	* @Title: getPrimaryKeyByUUID 
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String getPrimaryKeyByUUID(){
		return UUID.randomUUID().toString();
	}  
	/**  
	* 函数功能说明 TODO:获取当前登录用户实体类
	* hujc修改者名字
	* 2013-5-10修改日期
	* 修改内容
	* @Title: getCurrendUser 
	* @Description: TODO:
	* @param @return    设定文件 
	* @return Users    返回类型 
	* @throws 
	*/
	public static ShiroUser getCurrendUser(){
		Subject subject=SecurityUtils.getSubject();
		return (ShiroUser)subject.getSession().getAttribute(SHIRO_USER);
	}  
	
	/**  
	* 函数功能说明 TODO:高级查询hql条件拼接
	* hujc修改者名字
	* 2013-5-30修改日期
	* 修改内容
	* @Title: getSearchConditionsHQL 
	* @Description: 
	* @param @param asName
	* @param @param searchColumnNames
	* @param @param searchAnds
	* @param @param searchConditions
	* @param @param searchVals
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String getGradeSearchConditionsHQL(String asName,PageUtil pageUtil)
	{
		String searchAnds = pageUtil.getSearchAnds();
		String searchColumnNames=pageUtil.getSearchColumnNames();
		String searchConditions=pageUtil.getSearchConditions();
		String searchVals=pageUtil.getSearchVals();
		if(null!=searchColumnNames && searchColumnNames.trim().length()>0){
			StringBuffer sb=new StringBuffer();
			String[] searchColumnNameArray=searchColumnNames.split("\\,");
			String[] searchAndsArray=searchAnds.split("\\,");
			String[] searchConditionsArray=searchConditions.split("\\,");
			String[] searchValsArray=searchVals.split("\\,");
			for (int i = 0; i < searchColumnNameArray.length; i++) {
				if (searchColumnNameArray[i].trim().length() > 0 && searchConditionsArray[i].trim().length()>0) {
					/*if (i == 0) {
						sb.append(asName+"."+searchColumnNameArray[i].trim() + " " + searchConditionsArray[i].trim() + " " + searchValsArray[i].trim());
					} else {
					}*/
					String temp=searchValsArray[i].trim().replaceAll("\\'", "");
					if (HQL_LIKE.equals(searchConditionsArray[i].trim()))
					{
						sb.append(" " + searchAndsArray[i].trim() + " " + asName+IS_DOT+searchColumnNameArray[i].trim() + " " + searchConditionsArray[i].trim() + " " +"'%"+ temp+"%'");

					}else {
						sb.append(" " + searchAndsArray[i].trim() + " " + asName+IS_DOT+searchColumnNameArray[i].trim() + " " + searchConditionsArray[i].trim() + " " +"'"+ temp+"'");
					}
				}
			}
			if(sb.length()>0){
				return sb.toString();
			}
		}
		return NULL_STRING;
	}
	
	/**  
	* 函数功能说明 TODO:获得简单查询条件
	* hujc修改者名字
	* 2013-5-30修改日期
	* 修改内容
	* @Title: getSearchConditionsHQL 
	* @Description: 
	* @param @param asName
	* @param @param param
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String getSearchConditionsHQL(String asName ,Map<String, Object> param){
		StringBuffer sb=new StringBuffer();
		if (param != null && !param.isEmpty()) {
			for (String name : param.keySet())
			{
				if(!name.equals("sortName")&&!name.equals("orderBy")){
					sb.append(" and "+asName+Constants.IS_DOT+name+" = :"+name+"");
				}
			}
		}
		return sb.toString();
	}
	
	/**  
	* 函数功能说明 TODO:获得简单查询条件
	* hujc修改者名字
	* 2013-5-30修改日期
	* 修改内容
	* @Title: getSearchConditionsHQL 
	* @Description: 
	* @param @param asName
	* @param @param param
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String getSearchConditionsSQL(String asName ,Map<String, Object> param){
		StringBuffer sb=new StringBuffer();
		if (param != null && !param.isEmpty()) {
			for (String name : param.keySet())
			{
				if(!name.equals("sortName")&&!name.equals("orderBy")){
					sb.append(" and "+asName+Constants.IS_DOT+name+" ="+param.get(name)+"");
				}
			}
		}
		return sb.toString();
	}
	
	

	public static String[] getFiledName(Object o )
	{
		try
		{
			Field[] fields = o.getClass().getDeclaredFields();
			String[] fieldNames = new String[fields.length];
			for (int i = 0; i < fields.length; i++)
			{
				fieldNames[i] = fields[i].getName();
			}
			return fieldNames;
		} catch (SecurityException e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	public static Object getFieldValueByName(String fieldName, Object o)    
	{       
	   try    
	   {       
	       String firstLetter = fieldName.substring(0, 1).toUpperCase();       
	       String getter = "get" + firstLetter + fieldName.substring(1);       
	       Method method = o.getClass().getMethod(getter, new Class[] {});       
	       Object value = method.invoke(o, new Object[] {});       
	       return value;       
	   } catch (Exception e)    
	   {       
	       System.out.println("属性不存在");       
	       return "";       
	   }       
	}  
	
	  public static HashMap<String, Method> ConverBean(Class<?> drbean) {  
	        Class<?> stopClass = null;  
	        // 存放class信息  
	        BeanInfo drbeaninfo = null;  
	        // 存放属性信息  
	        PropertyDescriptor[] props;  
	        HashMap<String, Method> map = new HashMap<String, Method>();  
	        try {  
	            // 获取class中得属性方法信息  
	            drbeaninfo = Introspector.getBeanInfo(drbean, stopClass);  
	            // 把class中属性放入PropertyDescriptor数组中  
	            props = drbeaninfo.getPropertyDescriptors();  
	            for (int i = 0; i < props.length; i++) {  
	                // 获取属性所对应的set方法  
	                Method setMethod = props[i].getWriteMethod();  
	                // 判断属性是否有set方法 如果有放入map<属性名，set方法>中  
	                if (setMethod != null) {  
	                    String field = props[i].getName().toLowerCase();  
	                    map.put(field, setMethod);  
	                }  
	            }  
	        } catch (IntrospectionException e) {  
	            // TODO Auto-generated catch block  
	            e.printStackTrace();  
	        }  
	        return map;  
	    }
	
	/**  
	* 函数功能说明 TODO:获取客户端ip地址
	* hujc修改者名字
	* 2013-6-19修改日期
	* 修改内容
	* @Title: getIpAddr 
	* @Description: 
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String getIpAddr() {
		   HttpServletRequest request=ServletActionContext.getRequest();
	       String ip = request.getHeader("x-forwarded-for");
	       if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
	           ip = request.getHeader("Proxy-Client-IP");
	       }
	       if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
	           ip = request.getHeader("WL-Proxy-Client-IP");
	       }
	       if(ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
	           ip = request.getRemoteAddr();
	       }
	       return ip;
	   } 
	
	/**  
	* 函数功能说明 TODO:获取客户端mac地址
	* hujc修改者名字
	* 2013-6-19修改日期
	* 修改内容
	* @Title: getMacAddr 
	* @Description: 
	* @param @return    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public static String  getMacAddr()
	{
		String smac = "";
		try
		{
			UdpGetClientMacAddr umac = new UdpGetClientMacAddr(getIpAddr());
			smac = umac.GetRemoteMacAddr();
		} catch (Exception e)
		{
			e.printStackTrace();
		}
		return smac;
	}
	private static final int BUFFER_SIZE = 16 * 1024;
	 public static void copy(File src, String fullSavePath) {
	        InputStream in = null; 
	        OutputStream out = null; 
	        File newFile=new File(fullSavePath);
	        try { 
	            in = new BufferedInputStream(new FileInputStream(src), BUFFER_SIZE); 
	            out = new BufferedOutputStream(new FileOutputStream(newFile), 
	                    BUFFER_SIZE); 
	            byte[] buffer = new byte[BUFFER_SIZE]; 
	            int len = 0; 
	            while ((len = in.read(buffer)) > 0) { 
	                out.write(buffer, 0, len); 
	            } 
	            out.flush();
	        } catch (Exception e) { 
	            e.printStackTrace(); 
	        } finally { 
	            if (null != in) { 
	                try { 
	                    in.close(); 
	                } catch (IOException e) { 
	                    e.printStackTrace(); 
	                } 
	            } 
	            if (null != out) { 
	                try { 
	                    out.close(); 
	                } catch (IOException e) { 
	                    e.printStackTrace(); 
	                } 
	            } 
	        } 
	    }
	 public static String BASE_PATH =System.getProperty("erp");
	 public static String dbBackUp()
		{
			//生成临时备份文件
			SimpleDateFormat sd=new SimpleDateFormat("yyyyMMddHHmmss");
			String fineName="dbBackUp-"+sd.format(new Date());
			String sqlName=fineName+Constants.FILE_SUFFIX_SQL;
			String pathSql=BASE_PATH+"attachment"+File.separator+"dbBackUp";
			try {
				File filePathSql = new File(pathSql);
				if(!filePathSql.exists()){
					filePathSql.mkdir();
				}
				StringBuffer sbs = new StringBuffer();
				sbs.append("mysqldump ");
				sbs.append("-h 192.168.110.10 ");
				sbs.append("--user=root");
				sbs.append(" --password=fortune123");
				sbs.append(" --lock-all-tables=true ");
				sbs.append("--result-file="+pathSql+File.separator);
				sbs.append(sqlName+" ");
				sbs.append(" --default-character-set=utf8 ");
				sbs.append("ERP");
		        Runtime runtime = Runtime.getRuntime();
		        Process child = runtime.exec(sbs.toString());
		        //读取备份数据并生成临时文件
		        InputStream in = child.getInputStream();
		        OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(pathSql), "utf8");
		        BufferedReader reader = new BufferedReader(new InputStreamReader(in, "utf8"));
		        String line=reader.readLine();
		        while (line != null) {
		                writer.write(line+"\n");
		                line=reader.readLine();
		         }
		         writer.flush();
			} catch (Exception e) {
				
			}
			return sqlName;
		}
	 
	 /**
	  * 获取当前用户的actionLog
	  */
	 
	 public static SysActionLog getCurrentActionLog(){
		 Subject subject=SecurityUtils.getSubject();
		 return (SysActionLog)subject.getSession().getAttribute(ACTIONLOG);
	 }
	 public static String SYS_CONFIG_INIT_FILENAME = "sysconfig";
	 

	 public static String getAccKind(String str) {
			String s = "";
			try {
				if (!Tools.processNull(str).equals("")) {
					if (str.equals("0")) {
						s = "00";
					} else if (str.equals("1")) {
						s = "01";
					} else if (str.equals("2")) {
						s = "02";
					} else if (str.equals("3")) {
						s = "03";
					} else if (str.equals("4")) {
						s = "04";
					} else if (str.equals("5")) {
						s = "05";
					} else if (str.equals("6")) {
						s = "06";
					} else if (str.equals("7")) {
						s = "07";
					} else if (str.equals("8")) {
						s = "08";
					} else if (str.equals("9")) {
						s = "09";
					}

				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			return s;
		}
		
		public static String getApplyState(String str) {
			String s = "";
			//申领状态00-已申请,10-任务已生成，11-已发卫计委，12-卫计委审核不通，13-卫计委通过，14-已发银行，15-银行不通过，16-银行已通过， 
			//20-制卡中， 30-已制卡 40-已配送 50-已接收  60-已发放 70-已退卡，80-已回收 90注销)
			try {
				if (!Tools.processNull(str).equals("")) {
					if (str.equals("0")) {
						s = "00";
					} else if (str.equals("1")) {
						s = "10";
					} else if (str.equals("2")) {
						s = "20";
					} else if (str.equals("3")) {
						s = "30";
					} else if (str.equals("4")) {
						s = "40";
					} else if (str.equals("5")) {
						s = "50";
					} else if (str.equals("6")) {
						s = "60";
					} else if (str.equals("7")) {
						s = "70";
					} else if (str.equals("8")) {
						s = "80";
					} else if (str.equals("9")) {
						s = "90";
					}

				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			return s;
		}
		
		public static String getUnApplyState(String s) {
			String str = "";
			//申领状态00-已申请,10-任务已生成，11-已发卫计委，12-卫计委审核不通，13-卫计委通过，14-已发银行，15-银行不通过，16-银行已通过， 
			//20-制卡中， 30-已制卡 40-已配送 50-已接收  60-已发放 70-已退卡，80-已回收 90注销)
			try {
				if (!Tools.processNull(s).equals("")) {
					if (s.equals("00")) {
						str = "0";
					} else if (s.equals("10")) {
						str = "1";
					} else if (s.equals("20")) {
						str = "2";
					} else if (s.equals("30")) {
						str = "3";
					} else if (s.equals("40")) {
						str = "4";
					} else if (s.equals("50")) {
						str = "5";
					} else if (s.equals("60")) {
						str = "6";
					} else if (s.equals("70")) {
						str = "7";
					} else if (s.equals("80")) {
						str = "8";
					} else if (s.equals("90")) {
						str = "9";
					}

				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			return str;
		}
}
