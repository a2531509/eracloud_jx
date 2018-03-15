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
    <title>支付密码修改</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		$(function(){
			createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		});
		//读卡,对卡号进行复制，并设置读卡标志，并设置是好卡
		function readCard(){
			$.messager.progress({text : '正在验证卡信息,请稍后...'});
			cardinfo = getcardinfo();
			if(dealNull(cardinfo['card_No']).length == 0){
				$.messager.progress('close');
				$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！','error');
				return;
			}
			$('#cardNo').val(cardinfo['card_No']);
			validCard();
		}
		//验证卡信息
		function validCard(){
			$.post('cardService/cardServiceAction!getCardAndPersonInfo.action',"cardNo=" + $('#cardNo').val(),function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					$('#certType').combobox('setValue',data.person.certType);
					$('#cardType').combobox('setValue',data.card.cardType);
					if(dealNull(data.card.cardNo).length == 0){
						$.messager.alert('系统消息','验证卡片错误，卡号信息不存在，该卡不能进行联机账户密码修改。','error',function(){
							window.history.go(0);
						});
					}else{
						oldCardNo = data.card.cardNo;
						query();
					}
				}else{
					$.messager.alert('系统消息','验证卡信息时出现错误，请重试...','error',function(){
						window.history.go(0);//如果验证通过就进行查询
					});
				}
			},'json');
		}
		function query(){
			deteteGridAllRows('dg');
			if($("#certType").combobox('getValue').replace(/\s/g,'') == '' && $("#cardType").combobox('getValue').replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请选择查询证件类型或是卡类型！','error');
				return;
			}
			if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入查询证件号码或是卡号！','error');
				return;
			}
			$dg.datagrid('reload',{
				queryType:'0',//查询类型
				certType:$("#certType").combobox('getValue'), 
				certNo:$('#certNo').val(), 
				cardType:$("#cardType").combobox('getValue'),
				cardNo:$('#cardNo').val()
			});
		}
		/**原密码输入*/
		function getOldPwd(){
			if(oldCardNo != $('#cardNo').val()){
				$.messager.alert('系统消息','卡号已发生变化，请重新进行读卡，再进行密码修改！','error',function(){
					window.history.go(0);
				});
			}
			$('#oldPwd').val(getPlaintextPwd());
		}
		/**新密码输入*/
		function getNewPwd(){
			if(oldCardNo != $('#cardNo').val()){
				$.messager.alert('系统消息','卡号已发生变化，请重新进行读卡，再进行密码修改！','error',function(){
					window.history.go(0);
				});
			}
			$('#pwd').val(getPlaintextPwd());
			$('#confirmPwd').val(getPlaintextEnsurePwd());
		}
		//提交表单
		function submitForm(){
			if($('#cardNo').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请先进行读卡获取卡号信息！','error');
				return;
			}
			if(oldCardNo != $('#cardNo').val()){
				$.messager.alert('系统消息','卡号已发生变化，请重新进行读卡，再进行密码修改！','error',function(){
					window.history.go(0);
				});
			}
			var curRow = $dg.datagrid("getSelected");
			if(!curRow){
				$.messager.alert('系统消息','请至少选择一条记录进行联机账户支付密码修改！','error');
				return;
			}
			//已选择记录
			if($('#oldPwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入原密码！','error');
				return;
			}
			if($('#pwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入新密码！','error');
				return;
			}
			if($('#confirmPwd').val().replace(/\s/g,'') == ''){
				$.messager.alert('系统消息','请输入确认密码！','error');
				return;
			}
			if($('#pwd').val().replace(/\s/g,'') != $('#confirmPwd').val().replace(/\s/g,'')){
				$.messager.alert('系统消息','新密码和确认密码不相同！请重新输入！','error');
				$('#confirmPwd').val('');
				$('#confirmPwd').focus();
				return;
			}
			$.messager.confirm('系统消息','您确定要修改卡号为【' + curRow.CARD_NO + '】的联机支付密码吗？',function(is){
				if(is){
					$.messager.progress({text : '数据处理中，请稍后....'});
					var reqpara = "cardNo=" + $("#cardNo").val() + "&pwd=" + $("#pwd").val() + "&rec.agtCertType=" + $("#agtCertType").combobox('getValue') + "&oldPwd=" + $("#oldPwd").val();
					reqpara += "&rec.agtCertNo=" + $("#agtCertNo").val() + "&rec.agtName=" + $("#agtName").val() + "&rec.agtTelNo=" + $("#agtTelNo").val();
					$.post('pwdservice/pwdserviceAction!savePayPwdModify.action',reqpara,function(data,status){
						if(status == 'success'){
							if(data.status == "0"){
								showReport('联机账户支付密码修改',data.dealNo,function(){
									window.history.go(0);
								});
							}else{
								$.messager.progress('close');
								$.messager.alert('系统消息',data.msg,'error');
							}
						}else{
							$.messager.progress('close');
							$.messager.alert('系统消息','服务密码修改失败！','error');
						}
					},'json');
				}
			});
		}
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>个人联机账户支付密码</strong>进行修改操作！<span style="color:red;font-weight:700">注意：</span>如果原密码不存在，请进行联机账户支付密码重置！</span></span>
		</div>
	</div>
	  <div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;">
	  		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
		  		<div style="width:100%;display:none;" id="accinfodiv">
		  			<h3 class="subtitle">账户信息</h3>
		  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
				</div>
		  		<h3 class="subtitle">代理人信息</h3>
				<table style="width:100%;" class="tablegrid">
					<tr>
						<th class="tableleft">原密码：</th>
						<td class="tableright">
							<input id="oldPwd" type="password" class="textinput" name="oldPwd" maxlength="6"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton" onclick="getOldPwd()">密码输入</a>
						</td>
					 	<th class="tableleft">新密码：</th>
						<td class="tableright"><input id="pwd" type="password" class="textinput" name="pwd" maxlength="6"/></td>
						<th class="tableleft">确认密码：</th>
						<td class="tableright" colspan="3">
							<input name="confirmPwd" class="textinput" id="confirmPwd" type="password" maxlength="6"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="getNewPwd()">密码输入</a>
						</td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox" name="rec.agtCertType" value="1" style="width:174px;"/></td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text"  maxlength="18" validtype="idcard" /></td>
						<th class="tableleft">姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput"  maxlength="30"  /></td>
					 	<th class="tableleft">联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11"  validtype="mobile"/></td>
					</tr>
				</table>
			</form>			
	  </div>
  </body>
</html>