<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript">
	var $grid;
	var cardinfo;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"pwdservice/pwdserviceAction!servicePwdModifyQuery.action",
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			fitColumns:true,
			scrollbarSize:0,
			singleSelect:true,
			columns:[[
				 {field:"", checkbox:true},
		         {field:"CUSTOMER_ID",title:"客户编号",width:parseInt($(this).width() * 0.1),sortable:true},
		         {field:"NAME",title:"姓名",width:parseInt($(this).width()*0.1),sortable:true},
		         {field:"CERTTYPE",title:"证件类型",width:parseInt($(this).width()*0.1)},
		         {field:"CERT_NO",title:"证件号码",width:parseInt($(this).width()*0.15),sortable:true},
		         {field:"GENDER",title:"性别",width:80},
		         {field:"CUSTOMERSTATE",title:"客户状态",width:80}
             ]]
		});
	});
	function query(){
		if(dealNull($("#certNo").val()) == "" && dealNull($("#cardNo").val()) == ""){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号！","error");
			return;
		}
		$("#searchConts").form("reset");
		$grid.datagrid("load",{
			queryType:"0",
			certNo:$("#certNo").val(), 
			cardNo:$("#cardNo").val(),
			opType:0
		});
	}
	//提交表单
	function submitForm(){
		var curRow = $grid.datagrid("getSelected");
		if(!curRow){
			$.messager.alert("系统消息","请选择一条记录信息进行服务密码修改！","error");
			return;
		}
		if(dealNull($("#oldPwd").val()) == ""){
			$.messager.alert("系统消息","请输入原始密码！","error",function(){
				$("#oldPwd").focus();
			});
			return;
		}
		if(dealNull($("#pwd").val()) == ""){
			$.messager.alert("系统消息","请输入新密码！","error",function(){
				$("#pwd").focus();
			});
			return;
		}
		if(dealNull($("#confirmPwd").val()) == ""){
			$.messager.alert("系统消息","请输入确认密码！","error",function(){
				$("#confirmPwd").focus();
			});
			return;
		}
		if(dealNull($("#pwd").val()) != dealNull($("#confirmPwd").val())){
			$.messager.alert("系统消息","新密码和确认密码不相同，请重新输入！","error");
			$("#confirmPwd").val("");
			$("#confirmPwd").focus();
			return;
		}
		if(curRow.CUSTOMER_STATE != "0"){
			$.messager.alert("系统消息","客户状态不正常，无法进行服务密码修改！","error");
			return;
		}
		var certNo = curRow.CERT_NO;
		$.messager.confirm("系统消息","您确定要修改【" + curRow.NAME + "】的服务密码吗？",function(is){
			if(is){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.post("pwdservice/pwdserviceAction!saveServicePwd.action",$("#searchConts").serialize() + "&certNo=" + certNo,function(data,status){
					$.messager.progress("close");
					if(status == "success"){
						$.messager.alert("系统消息",data.message,(data.status ? "info" :"error"),function(){
							if(data.status){
								showReport("服务密码修改",data.dealNo,function(){
									window.history.go(0);
								});
							}
						});
					}else{
						$.messager.alert("系统消息","服务密码修改失败，请重新进行操作！","error");
					}
				},"json");
			}
		});
	}
	//读取卡信息
	function readcard(){
		$.messager.progress({text:"正在获取卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}else{
			$("#cardNo").val(cardinfo["card_No"]);
			query();
		}
	}
	//读取客户证件信息
	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息信息,请稍后..."});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}else{
			$.messager.progress("close");
		}
		$("#certNo").val(o["cert_No"]);
		query();
	}
	//读取代理人信息证件信息
	function readIdCard2(){
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
	//原密码
	function inpwd(){
		$.messager.progress({text:"正在获取密码信息，请稍后...."});
		$("#oldPwd").val(getPlaintextPwd());
		$.messager.progress("close");
	}
	//新密码
	function innewpwd(){
		$.messager.progress({text:"正在获取密码信息，请稍后...."});
		$("#pwd").val(getPlaintextPwd());
		$("#confirmPwd").val(getPlaintextEnsurePwd());
		$.messager.progress("close");
	}
</script>
<n:initpage title="个人服务密码进行修改操作！服务密码一般用于网站登录或是终端信息查询!">
	<n:center>
		<div id="tb">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="20"/></td>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
					<td class="tableright">
						<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-readCard'"    onclick="readcard()">读卡</a>
						<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-readIdcard'"  onclick="readIdCard()">读身份证</a>
						<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-search'"      onclick="query()">查询</a>
						<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-save'"        onclick="submitForm()">确定</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="用户信息"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:200px; width:auto;overflow:hidden;text-align:center;border-left:none;border-bottom:none;">
  		<form id="searchConts" class="datagrid-toolbar" style="width:100%;height:100%">
	  		<h3 style="background-position:left center; background-image:url(extend/fromedit.png);background-repeat:no-repeat;margin:0;padding:5px 0;line-height:100%;text-align:left;font-weight:normal;padding-left:17px;font-size:12px;color:rgb(153,153,153);border-width:1px;border-style:solid;border-color:#E5E5E5;">密码信息</h3>
			<table style="width:100%;" class="tablegrid">
				<tr>
				 	<th class="tableleft">原始密码：</th>
				 	<td class="tableright">
						<input id="oldPwd" type="password" class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
						<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="inpwd()">密码输入</a>
				 	</td>
				 	<th class="tableleft">新密码：</th>
					<td class="tableright"><input id="pwd" type="password" class="textinput" name="pwd"  maxlength="6" readonly="readonly"/></td>
					<th class="tableleft">确认密码：</th>
					<td class="tableright" colspan="1"><input name="confirmPwd" class="textinput" id="confirmPwd" type="password" maxlength="6" readonly="readonly"/></td>
					<td class="tableleft"><a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="innewpwd()">密码输入</a></td>
				</tr>
				<tr>
					<td colspan="7"><h3 class="subtitle">代理人信息</h3></td>
				</tr>
				<tr>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1"/></td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright"><input name="rec.agtCertNo" class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
					<td class="tableleft">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
				<tr>
					<th class="tableleft">代理人联系电话：</th>
					<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11"/></td>
					<td class="tableleft" colspan="5">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
					</td>
				</tr>
			</table>
		</form>			
	</div>
</n:initpage>
