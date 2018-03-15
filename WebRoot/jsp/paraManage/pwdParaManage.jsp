<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>钱包账户充值</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">   
<jsp:include page="../../layout/script.jsp"></jsp:include>
<style type="text/css">
	.label_left{text-align:right;padding-right:2px;height:30px;font-weight:700;}
	.label_right{text-align:left;padding-left:2px;height:30px;}
	#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
	#tb table{border-left:none;border-right:none;}
	body{font-family:'微软雅黑'}
</style> 
<script type="text/javascript">
	
	$(function(){
		addNumberValidById("sys_Login_Pwd_Err_Num");
		addNumberValidById("trade_Pwd_Err_Num");
		addNumberValidById("serv_Pwd_Err_Num");
	});
	function tijiao(){
 		if(dealNull($("#sys_Login_Pwd_Err_Num").val()) == ""){
			$.messager.alert("系统消息","请输入柜员登录密码输入错误限制次数！","error",function(){
				$("#sys_Login_Pwd_Err_Num").focus();
			});
			return;
		}
 		if(dealNull($("#trade_Pwd_Err_Num").val()) == ""){
			$.messager.alert("系统消息","请输入交易密码输入错误限制次数！","error",function(){
				$("#trade_Pwd_Err_Num").focus();
			});
			return;
		}
 		if(dealNull($("#serv_Pwd_Err_Num").val()) == ""){
			$.messager.alert("系统消息","请输入服务密码输入错误限制次数！","error",function(){
				$("#serv_Pwd_Err_Num").focus();
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要保存密码错误次数限制参数？", function(is) {
			if(is){
				$.messager.progress({text : "正在进行操作，请稍后...."});
				$.ajax({url:"cardParaManage/cardConfigAction!saveErrPwdPara.action",
					    dataType:"json",
					    data:{
					    	sys_Login_Pwd_Err_Num:$("#sys_Login_Pwd_Err_Num").val(),
					    	trade_Pwd_Err_Num:$("#trade_Pwd_Err_Num").val(),
					    	serv_Pwd_Err_Num:$("#serv_Pwd_Err_Num").val()
					    },
					    success:function(data){
							if(data.status != "0"){
								$.messager.progress("close");
								$.messager.alert("系统消息",data.msg,"error");
							}else if(data.status == "0"){
								$.messager.progress("close");
								$.messager.alert("系统消息",data.msg,"info");
							}
						},
						error:function(){
							$.messager.progress("close");
							$.messager.alert("系统消息","钱包账户充值请求出现错误，请重试！","error",function(){
								window.history.go(0);
							});
						}
				});
			}
		});
	}
	
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对卡片进行<span class="label-info"><strong>密码输入错误次数进行设置！<span style="color:red;"></span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:100%;margin:0px;width:auto;border-left:none;border-bottom:none;">
	  	<div id="tb"  style="padding:2px 0;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:true,tools:'#toolspanel'" title="钱包账户充值">
			<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft">系统操作员登录密码输入错误限制次数：</td>
					<td class="tableright"><input name="sys_Login_Pwd_Err_Num" id="sys_Login_Pwd_Err_Num" type="text" class="textinput" value="${sys_Login_Pwd_Err_Num}"/></td>
					<td class="tableleft">交易密码输入错误限制次数：</td>
					<td class="tableright"><input name="trade_Pwd_Err_Num" id="trade_Pwd_Err_Num" type="text" class="textinput"  value="${trade_Pwd_Err_Num}"/></td>
					<td class="tableleft">服务密码输入错误限制次数：</td>
					<td class="tableright"><input id="serv_Pwd_Err_Num" type="text" class="textinput" name="serv_Pwd_Err_Num"  value="${serv_Pwd_Err_Num}" />
						<a  data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="tijiao()">保存参数</a>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>
