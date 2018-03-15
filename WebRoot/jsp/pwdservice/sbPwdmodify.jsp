<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="../../layout/initpage.jsp" %>
<script type="text/javascript">
	var oldCardNo = "";
	var cardinfo;
	var flag = false;
	var errMsg;
	var nums = 0;

	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		
		$("#dg").datagrid({
			url : "pwdservice/pwdserviceAction!getSBPwdServInfos.action",
			fit : true,
			toolbar : $("#tb"),
			striped : true,
			border : false,
			rownumbers : true,
			showFooter : true,
			fitColumns : true,
			singleSelect : true,
			pagination : true,
			pageSize : 10,
			columns : [ [
				{field:"DEAL_NO", title:"业务流水", sortable:true, width : parseInt($(this).width() * 0.04)},
				{field:"DEAL_CODE", title:"业务代码", sortable:true, width : parseInt($(this).width() * 0.05)},
				{field:"DEAL_CODE_NAME", title:"业务名称", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"CARD_NO", title:"卡号", sortable:true, width : parseInt($(this).width() * 0.12)},
				{field:"CUSTOMER_ID", title:"客户编号", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"CUSTOMER_NAME", title:"客户名称", sortable:true, width : parseInt($(this).width() * 0.04)},
				{field:"BIZ_TIME", title:"操作时间", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"FULL_NAME", title:"受理网点", sortable:true, width : parseInt($(this).width() * 0.1)},
				{field:"USER_ID", title:"受理柜员", sortable:true, width : parseInt($(this).width() * 0.06)},
				{field:"NOTE", title:"备注", sortable:true, width : parseInt($(this).width() * 0.15)}
			]],
			onLoadSuccess : function(data) {
				if (data.status != "0") {
					$.messager.alert('系统消息', data.errMsg, 'error');
					errMsg = data.errMsg;
					flag = false;
				} else {
					$("#form").form("reset");
					flag = true;
				}
			},
			onBeforeLoad : function(){
				var cardNo = $("#cardNo").val();
				
				if(cardNo == ""){
					return false;
				}
				return true;
			}
		});
	})
	
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}
		clear();
		$("#cardNo").val(cardinfo["card_No"]);
		$.messager.progress("close");
		query();
	}
	
	function getOldPwd(){
		oldCardNo = $("#cardNo").val();
		if($("#cardNo").val() == ""){
			$.messager.alert("系统消息","请先进行读卡，以获取卡片信息！","error");
			return;
		}
		
		if(!flag){
			$.messager.alert("系统消息","不能修改密码, " + errMsg,"error");
			return;
		}
		
		$("#oldPwd").val(getPlaintextPwd(1));
	}
	
	function getNewPwd(){
		if($("#cardNo").val() == ""){
			$.messager.alert("系统消息","请先进行读卡，以获取卡片信息！","error");
			return;
		}
		
		if(!flag){
			$.messager.alert("系统消息","不能修改密码, " + errMsg,"error");
			return;
		}
		
		$("#pwd").val(getPlaintextPwd());
		$("#confirmPwd").val(getPlaintextEnsurePwd());
	}
	
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	
	function query(){
		var cardNo = $("#cardNo").val();
		
		if(cardNo == ""){
			$.messager.alert("系统消息","卡号为空, 请先读卡！","info");
		}
		
		$("#dg").datagrid("load", {
			cardNo:cardNo
		});
	}
	
	function modify(){
		var cardNo = $("#cardNo").val();
		var oldPwd = $("#oldPwd").val();
		var newPwd = $("#pwd").val();
		
		if(cardNo.replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请先进行读卡获取卡号信息！","error");
			return;
		}

		if(!flag){
			$.messager.alert("系统消息","不能修改密码, " + errMsg,"error");
			return;
		}
		
		if(oldPwd.replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输原密码！","error");
			return;
		}
		
		if($("#pwd").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入新密码！","error");
			return;
		}
		if($("#confirmPwd").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入确认密码！","error");
			return;
		}
		if($("#pwd").val().replace(/\s/g,"") != $("#confirmPwd").val().replace(/\s/g,"")){
			$.messager.alert("系统消息","新密码和确认密码不相同！请重新输入！","error");
			$("#confirmPwd").val("");
			$("#confirmPwd").focus();
			return;
		}
		
		if(!judgeTouchPwd2(oldPwd)){
			clearPwd();
			return;
		}
		
		$.messager.confirm("系统消息","您确定要修改卡号为【" + cardNo + "】的医保密码吗？",function(is){
			if(is){
				$.messager.progress({text : "正在修改密码，请不要取走卡片..."});
				if(!modifyTouchPwd(oldPwd,newPwd,nums)){
					$.messager.progress("close");
					$.messager.alert("系统消息","修改密码失败","error");
					return;
				}
				$.messager.progress("close");
				$.messager.progress({text : "密码修改成功, 正在同步业务日志..."});
				var reqpara = "cardNo=" + $("#cardNo").val() + "&pwd=" + $("#pwd").val() + "&rec.agtCertType=" + $("#agtCertType").combobox("getValue") ;
				reqpara += "&rec.agtCertNo=" + $("#agtCertNo").val() + "&rec.agtName=" + $("#agtName").val() + "&rec.agtTelNo=" + $("#agtTelNo").val();
				$.post("pwdservice/pwdserviceAction!saveSbPwd.action",reqpara,function(data,status){
						$.messager.progress("close");
						if(data.status == "0"){
							$.messager.alert("系统消息",data.message, "info");
							showReport("医保密码修改",data.dealNo,function(){
								window.history.go(0);
							});
						}else{
							$.messager.alert("系统消息",data.message,"error");
						}
						
						query();
						clear();
				},"json");
			}
		});
	}
	
	function clear(){
		$("#cardNo").val("");
		$("#oldPwd").val("");
		$("#confirmPwd").val("");
		$("#pwd").val("");
		$("#agtCertType").combobox("select", "");
		$("#agtCertNo").val("");
		$("#agtName").val("");
		$("#agtTelNo").val("");
	}
	
	function clearPwd(){
		$("#oldPwd").val("");
		$("#confirmPwd").val("");
		$("#pwd").val("");
	}
	
	function judgeTouchPwd2(pwd){
		try{
			var isOpenPortOk = openTouchPort();
			if(!isOpenPortOk){
				nums = 0;
				return false;
			}
			if(dealNull(pwd).length != 6 || typeof(pwd) != "string"){
				//$.messager.alert("系统消息","输入密码长度不正确！","error");
				nums = 0;
				return false;
			}
			CardCtl.CardTouchPINVerify(pwd);
			if(CardCtl.Status == 0){
				nums = 0;
				return true;
			}else{
				$.messager.alert("系统消息", cardgeterrmessage(CardCtl.Status), "error");
				if(CardCtl.Status == -200069){
					nums = 5;
				}if(CardCtl.Status == -200070){
					nums = 4;
				}if(CardCtl.Status == -200071){
					nums = 3;
				}if(CardCtl.Status == -200072){
					nums = 2;
				}if(CardCtl.Status == -200073){
					nums = 1;
				}if(CardCtl.Status == -200074){
					nums = 6;
				}else{
					nums = 0;
					//$.messager.alert("系统消息",cardgeterrmessage(CardCtl.Status),"error");
				}
				return false;
			}
		}catch(e){
			nums = 0;
			errMsg = "";
			for (i in e) {
				errMsg += i + ":" + eval("e." + i) + "<br/>";
			}
			//$.messager.alert('系统消息',errMsg,'error');
			return false;
		}finally {
			closeTouchPort();
		}
	}
	
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<n:initpage
	title="个人医保密码</strong>进行修改操作！<span style='color:red;font-weight:700'>">
	<n:center>
		<div id="tb">
			<table class="tablegrid">
				<tr>
					<td class="tableleft" style="width: 8%">卡号：</td>
					<td class="tableright" style="width: 17%"><input name="cardNo"
						class="textinput" id="cardNo" type="text" readonly="readonly" /></td>
					<td style="padding-left: 2px"><a
						style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-readCard'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="readCard()">读卡</a>&nbsp; <a
						style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-search'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="query()">查询</a></td>
				</tr>
			</table>
		</div>
		<table id="dg" title="医保密码服务信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true"
		style="height: 300px; width: auto; text-align: center; overflow: hidden; border-left: none; border-bottom: none;">
		<form id="form" method="post" class="datagrid-toolbar"
			style="width: 100%; height: 100%">
			<table style="width: 100%;" class="tablegrid">
				<tr>
					<td colspan="8">
						<h3 class="subtitle">密码信息</h3>
					</td>
				</tr>
				<tr>
					<th class="tableleft">原密码：</th>
					<td class="tableright"><input id="oldPwd" type="password"
						class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
						<a style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-pwdbtn'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="getOldPwd()">密码输入</a></td>
					<th class="tableleft">新密码：</th>
					<td class="tableright"><input id="pwd" type="password"
						class="textinput" name="pwd" maxlength="6" readonly="readonly"/></td>
					<th class="tableleft">确认新密码：</th>
					<td class="tableright" colspan="3"><input name="confirmPwd"
						class="textinput" id="confirmPwd" type="password" maxlength="6"
						readonly="readonly" /> <a
						style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-pwdbtn'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="getNewPwd()">密码输入</a>
							<shiro:hasPermission name="savePayPwdModify">
								<a href="javascript:void(0);" class="easyui-linkbutton"
									data-options="plain:false,iconCls:'icon-save'"
									onclick="modify()">修改密码</a>
							</shiro:hasPermission>
						</td>
				</tr>
				<tr>
					<td colspan="8">
						<h3 class="subtitle">代理人信息</h3>
					</td>
				</tr>
				<tr>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright"><input id="agtCertType" type="text"
						class="easyui-combobox" name="rec.agtCertType" value="1" /></td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright"><input name="rec.agtCertNo"
						class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard"
						maxlength="18" /></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright"><input name="rec.agtName" id="agtName"
						type="text" class="textinput" maxlength="30" /> <a
						style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-readIdcard'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="readIdCard()">读身份证</a> <a
						style="text-align: center; margin: 0 auto;"
						data-options="plain:false,iconCls:'icon-readCard'"
						href="javascript:void(0);" class="easyui-linkbutton"
						onclick="readSMK2()">读市民卡</a></td>
				</tr>
				<tr>
					<th class="tableleft">代理人联系电话：</th>
					<td class="tableright"><input name="rec.agtTelNo"
						id="agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile"
						maxlength="11" /></td>
					<td colspan="6"></td>
				</tr>
			</table>
		</form>
	</div>
</n:initpage>
