<%@page import="com.erp.util.Constants"%>
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
    <title>${ACC_KIND_NAME_LJ }充值撤销</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		 zhuguan("zgOperId");
		 createSysCode({id:"certType",codeType:"CERT_TYPE", value:"<%=Constants.CERT_TYPE_SFZ%>"});
		 createSysCode({id:"cardType",codeType:"CARD_TYPE",codeValue:"100",isShowDefaultOption:true});
		 $.autoComplete({
				id:"certNo",
				text:"cert_no",
				value:"name",
				table:"base_personal",
				keyColumn:"cert_no"
				//minLength:"1"
			});
		 $grid = createDataGrid({
			 id:"dg",
			 url:"recharge/rechargeAction!onlineAccRechargeQuery.action",
			 idField:"V_V",
			 fitColumns:false,
			 scrollbarSize:0,
			 frozenColumns:[[
				 {field:"V_V",title:"",sortable:true,checkbox:true},
				 {field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width() * 0.05)},
				 {field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.08)},
				 {field:"ACC_NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.06)},
				 {field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15),fixed:true},
				 {field:"CARDTYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)}
			 ]],
			 columns:[[
				 {field:"ACC_NO",title:"账户号",sortable:true,width:parseInt($(this).width() * 0.05)},
				 {field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.08)},
				 {field:"ACCBAL",title:"充值前账户余额",sortable:true,align:"right",width:parseInt($(this).width() * 0.1)},
				 {field:"AMT",title:"充值金额",sortable:true,align:"right",width:parseInt($(this).width() * 0.05)},
				 {field:"DEALDATE",title:"充值日期",sortable:true,width:parseInt($(this).width() * 0.12)},
				 {field:"DEALSTATE",title:"记录状态",sortable:true},
	        	 {field:"CLR_DATE",title:"清分日期",sortable:true},
	        	 {field:"FULL_NAME",title:"网点",sortable:true},
	        	 {field:"NAME",title:"柜员",sortable:true},
	        	 {field:"NOTE",title:"备注",sortable:true}
             ]]
		 });
		 var pager = $grid.datagrid("getPager");
		 pager.pagination({
	     	  buttons:$("#zhuguanPwdDiv")
		 });
		 $.addNumber("dealNo");
	});
	function query(){
		/* if($("#certType").combobox("getValue").replace(/\s/g,"") == "" && $("#cardType").combobox("getValue").replace(/\s/g,"") == "" && $("#dealNo").val().replace(/\s/g) == ""){
			$.messager.alert("系统消息","请选择查询证件类型或是卡类型！","error");
			return;
		} */
		if($("#certNo").val().replace(/\s/g,"") == "" && $("#cardNo").val().replace(/\s/g,"") == "" && $("#dealNo").val().replace(/\s/g) == ""){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号，流水号！","error");
			return;
		}
		$grid.datagrid("load",{
			queryType:"0",
			dealNo:$("#dealNo").val(),
			certType:$("#certType").combobox("getValue"), 
			certNo:$("#certNo").val(), 
			cardType:$("#cardType").combobox("getValue"),
			cardNo:$("#cardNo").val()
		});
	}
	function saveCancel(){
		var temprow = $grid.datagrid("getSelected");
		if(temprow){
			$.messager.confirm("系统消息","您确定要撤销卡号为【" + temprow.CARD_NO + "】，流水号 = " + temprow.DEAL_NO + "的${ACC_KIND_NAME_LJ }充值记录吗？",function(is){
				if(is){
					$.messager.progress({text : "正在进行撤销,请稍后..."});
					$.post("recharge/rechargeAction!onlineAccRechargeCancel.action",{cardNo:temprow.CARD_NO,dealNo:temprow.DEAL_NO,zgOperId:$("#zgOperId").combobox("getValue"),pwd:$("#pwd").val()},function(data,status){
						$.messager.progress("close");
						if(status == "success"){
							if(data.status != "0"){
								$.messager.alert("系统消息",data.msg,"error");
							}else if(data.status == "0"){
								showReport("${ACC_KIND_NAME_LJ }充值撤销",data.dealNo,function(){
									window.history.go(0);
								});
							}
						}else{
							$.messager.alert(",系统消息","${ACC_KIND_NAME_LJ }充值撤销出现错误，请重试！","error");
						}
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值撤销，请选择一条充值记录！","error");
			return;
		}
	}
	function readCard(){
		try{
			var cardinfo = getcardinfo();
			if(dealNull(cardinfo["card_No"]).length == 0){
				$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！","error");
				return;
			}else{
				$("#cardNo").val(cardinfo["card_No"]);
			}
			query();
		}catch(e){
			errorsMsg = "";
			for (i in e) {
				errorsMsg += i + ":" + eval("e." + i) + "\n";
			}
			$.messager.alert("系统消息",errorsMsg,"error");
		}
	}
	function readIdCard(){
		try{
			var certinfo = getcertinfo();
			if(dealNull(certinfo["cert_No"]).length == 0){
				return;
			}
			$("#certType").combobox("setValue","1");
			$("#certNo").val(certinfo["cert_No"]);
			query();
		}catch(e){
			errorsMsg = "";
			for (i in e) {
				errorsMsg += i + ":" + eval("e." + i) + "\n";
			}
			$.messager.alert("系统消息",errorsMsg,"error");
		}
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>${ACC_KIND_NAME_LJ }充值记录</strong></span><span class="label-info">进行撤销操作！<span style="color:red;font-weight:600">注意：</span>只有当日且充值成功的记录才能进行${ACC_KIND_NAME_LJ }充值撤销！</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
	  	<div id="tb" style="padding:2px 0">
			<table style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft">流水号：</td>
					<td class="tableright"><input id="dealNo" name="dealNo" type="text" class="textinput"/></td>
					<td class="tableleft">证件类型：</td>
					<td class="tableright"><input id="certType" name="certType" type="text" class="textinput" /></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
				</tr>
				<tr>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;"/></td>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
					<td align="center" colspan="2">
						<shiro:hasPermission name="onlinerechargecanelreadcard">
							<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="onlinerechargecanelreadidcard">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="onlinerechargecanelquery">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="onlinerechargecanelsave">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-cancel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCancel()">确定撤销</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="${ACC_KIND_NAME_LJ }充值记录"></table>
  		<div id="zhuguanPwdDiv">
  			<table>
	  			<tr> 
	  				<td width="150px" align="right">授权柜员：</td>
	  				<td><input type="text" class="textinput" name="zgOperId" id="zgOperId" /></td>
	  				<td align="right">密码：</td>
	  				<td><input type="password" class="textinput" name="pwd" id="pwd" maxlength="6"/></td>
	  			</tr>
  			</table>
  		</div>
	</div>
</body>
</html>
