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
<title>网点存款</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
$(function(){
	//提示错误
	if('${defaultErrorMsg}'.length > 0){
		$.messager.alert('系统消息','${defaultErrorMsg}','error');
	}
	$("#frzAmt").validatebox({required:true,invalidMessage:"<span style=\"color:red\">网点存款财务未确认金额。</span>",missingMessage:"<span style=\"color:red;\">网点存款财务未确认金额。</span>"});
	$("#totalAmt").validatebox({required:true,invalidMessage:"请输入网点存款金额<br/><span style=\"color:red\">提示：存款金额不能大于当前网点最大可存款余额。</span>",missingMessage:"请输入网点存款金额<br/><span style=\"color:red\">提示：存款金额不能大于当前网点最大可存款余额。</span>"});
	$("#totalAmt2").validatebox({required:true,invalidMessage:"请输入确认存款金额<br/><span style=\"color:red\">提示：确认存款金额不能大于当前网点最大可存款余额。</span>",missingMessage:"请输入确认存款金额<br/><span style=\"color:red\">提示：确认存款金额必须等于当前网点最大可存款余额。</span>"});
	$("#td_blc22").validatebox({required:true,invalidMessage:"<span style=\"color:red\">网点最大可存款金额 = 网点现有余额 - 财务未确认金额（冻结金额）</span>",missingMessage:"<span style=\"color:red\">网点最大可存款金额 = 网点现有余额 - 财务未确认金额（冻结金额）</span>"});
	$("#frzAmt").validatebox("validate");
	$("#totalAmt").validatebox("validate");
	$("#totalAmt2").validatebox("validate");
	$("#td_blc22").validatebox("validate");
	
	$("#dg2").datagrid({
		loader:function(param, success, error){
			$.post("cashManage/cashManageAction!queryCashBoxDetail.action", param, function(data){
				if(data.status != 0){
					error();
					return;
				}
				
				var tableData = new Object();
				var row = new Array();
				var num = 0;
				if(data.otherOper){
					var otherOper = data.otherOper;
					for(var i in otherOper){
						row.unshift({userId:otherOper[i].userId, name:otherOper[i].name, rcAmt:otherOper[i].rcAmt, bhkAmt:otherOper[i].bkAmt + otherOper[i].hkAmt, tlAmt:otherOper[i].tlAmt});
						num++;
					}
				}
				
				if(data.curOper){
					var curOper = data.curOper;
					row.unshift({userId:curOper.userId, name:curOper.name, rcAmt:curOper.rcAmt, bhkAmt:curOper.bkAmt + curOper.hkAmt, tlAmt:curOper.tlAmt});
					num++;
				}
				
				var footer = [];
				if(data.curOperTotal){
					var rcAmt = 0;
					var bhkAmt = 0;
					
					for(var i in row){
						rcAmt += row[i].rcAmt;
						bhkAmt += row[i].bhkAmt;
					}
					
					var curOperTotal = data.curOperTotal;
					footer.unshift({userId:curOperTotal.userId, name:curOperTotal.name, rcAmt:rcAmt, bhkAmt:bhkAmt, tlAmt:curOperTotal.tlAmt});
				}
				
				tableData.rows = row;
				tableData.total = num;
				tableData.status = data.status;
				tableData.footer = footer;
				
				success(tableData);
			}, "json");
		},
		toolbar : $("#tb2"),
		fit : true,
		fitColumns : true,
		singleSelect : true,
		rownumbers : true,
		striped : true,
		border : false,
		showFooter : true,
		columns : [[
			{field:"", checkbox:true},
			{field:"userId", title:"柜员编号", sortable:true, width:parseInt($(this).width() * 0.1)},
			{field:"name", title:"柜员姓名", sortable:true, width:parseInt($(this).width() * 0.1)},
			{field:"rcAmt", title:"充值金额", sortable:true, width:parseInt($(this).width() * 0.1), formatter:function(value){
				return $.foramtMoney(Number(value).div100());
			}},
			{field:"bhkAmt", title:"补换卡金额", sortable:true, width:parseInt($(this).width() * 0.1), formatter:function(value){
				return $.foramtMoney(Number(value).div100());
			}},
			{field:"hkAmt", title:"换卡金额", hidden:true, sortable:true, width:parseInt($(this).width() * 0.1), formatter:function(value){
				return $.foramtMoney(Number(value).div100());
			}},
			{field:"tlAmt", title:"总计", sortable:true, width:parseInt($(this).width() * 0.1), formatter:function(value){
				return $.foramtMoney(Number(value).div100());
			}}
		]],
		onLoadSuccess : function(data) {
			if (data.status != "0") {
				$.messager.alert('系统消息', data.errMsg, 'warning');
			}
		}
	});
});
function validRmb(obj){
	var v = obj.value;
	var exp = /^\d*(\.?\d{0,2})?$/g;
	if(!exp.test(v)){
		obj.value = v.substring(0,v.length - 1);
	}
}
function subTj(){
	if($('#totalAmt').val().replace(/\s/g,'').length == 0){
		$.messager.alert("系统消息","请输入网点存款金额！","error",function(){
			$('#totalAmt').focus();
		});
		return;
	}
	if($('#totalAmt2').val().replace(/\s/g,'').length == 0){
		$.messager.alert("系统消息","请输入确认存款金额！","error",function(){
			$('#totalAmt2').focus();
		});
		return;
	}
	if(Number($('#totalAmt').val()) != Number($('#totalAmt2').val())){
		$.messager.alert("系统消息","网点存款金额和确认存款金额不一致，请重新输入！","error",function(){
			$('#totalAmt2').val('');
	   		$('#totalAmt2').focus();
		});
		return;
	}
	if(parseFloat($("#totalAmt").val()) > parseFloat($("#td_blc22").val())){
		$.messager.alert("系统消息","存款金额不能大于当前网点最大可存款余额，请重新输入！","error",function(){
			$('#totalAmt').val("");
			$('#totalAmt').focus();
		});
		return;
	}
	/* if($('#bankNo').val().replace(/\s/g,'').length == 0){
		$.messager.alert("系统消息","请银行存款凭证号！","error",function(){
			$('#bankNo').focus();
		});
		return;
	} */
	$.messager.confirm('系统消息','您确定要进行网点存款吗？<br>存款金额：' + parseFloat($('#totalAmt').val()).toFixed(2) + '<br>存款凭证：' + $('#bankNo').val(), function(is) {
		if(is){
			$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			$.post('/cashManage/cashManageAction!certainDepositPre.action',$('#tellerTransfer').serialize(),function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					$.messager.alert('系统消息',data.msg,(data.status == '0' ? 'info' : 'error'),function(){
						if(data.status == '0'){
							showReport('网点存款',data.dealNo,function(){
								window.location.href = window.location.href + "?mm=" + Math.random();
							});
						}
					});
				}else{
					$.messager.alert('系统消息','网点存款出现错误，请稍后重试！','error');
				}
			},'json');
		}
	});
}

function printCashBoxDetail() {
	$.messager.progress({text:"数据处理中..."});
	$.post("cashManage/cashManageAction!printCashBoxDetail.action", function(data){
		$.messager.progress("close");
		if(data.status != 0){
			jAlert("打印凭证失败, " + data.errMsg, "error");
			return;
		}
		
		showReport("柜员现金明细凭证", data.dealNo);
	}, "json");
}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>网点存款</strong></span>进行操作!</span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;">
		<form id="tellerTransfer">
			<div title="网点信息" class="easyui-panel" data-options="fit:false,border:false,iconCls:'icon-grid-title'" style="width:100%;border-left:none;border-bottom:none;">   
			   <table cellpadding="0" cellspacing="0" style="width:100%;border-left:none;border-bottom:none;" class="tablegrid datagrid-toolbar">
					<tr>
						<td class="tableleft" width="20%">柜员所属网点：</td>
						<td class="tableright" width="30%"><input type="text" readonly="readonly" disabled="disabled" value="${currentBranchName}" class="textinput"  style="width:174px;"/></td>
						<td class="tableleft" width="20%">柜员编号：</td>
						<td class="tableright" width="30%"><input type="text" readonly="readonly" disabled="disabled" value="${currentOperatorId}" class="textinput" style="width:174px;"/></td>
					</tr>
					<tr>
						<td class="tableleft">柜员名称：</td>
						<td class="tableright"><input type="text" readonly="readonly" disabled="disabled" value="${currentOperatorName}" class="textinput" style="width:174px;"/></td>
						<td class="tableleft">网点现有余额：</td>
						<td class="tableright"><input type="text" readonly="readonly" disabled="disabled" value="${totalAmt}" class="textinput"  style="width:174px;"/><span style="color:red;margin-left:9px;font-size:9px;">单位：元</span></td>
					</tr>
				</table>
			</div> 
			<div title="存款信息" class="easyui-panel"  data-options="fit:false,border:false,iconCls:'icon-grid-title'" style="width:100%">
				<table cellpadding="0" cellspacing="0" style="width:100%;" class="tablegrid datagrid-toolbar">
					<tr>
						<td class="tableleft" width="20%">冻结金额：</td>
						<td class="tableright" width="30%"><input type="text" class="textinput" id="frzAmt" name="frzAmt" readonly="readonly" value="${frzAmt}"/><span style="color:red;margin-left:9px;font-size:9px;">单位：元</span></td>
						<td class="tableleft" width="20%">最大可存款金额：</td>
						<td class="tableright" width="30%"><input id="td_blc22" type="text" readonly="readonly"  value="${availableAmt}" class="textinput" name="td_blc22"/><span style="color:red;margin-left:9px;font-size:9px;">单位：元</span></td>
					</tr>
					<tr>
						<td class="tableleft">网点存款金额：</td>
						<td class="tableright"><input type="text" class="textinput easyui-validatebox" id="totalAmt" value="${availableAmt}" name="totalAmt" readonly="readonly"/><span style="color:red;margin-left:9px;font-size:9px;">单位：元</span></td>
						<td class="tableleft">确认存款金额：</td>
						<td class="tableright"><input type="text" class="textinput easyui-validatebox" name="totalAmt2"  id="totalAmt2" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/><span style="color:red;margin-left:9px;font-size:9px;">单位：元</span></td>
					</tr>
					<tr>
						<td class="tableleft">银行存款凭证：</td>
						<td class="tableright"><input id="bankNo" type="text"  name="bankNo" class="textinput"/></td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td class="tableright" colspan="4" style="text-align:center;">
							<shiro:hasPermission name="certainDeposit">
								<a title="点击【确定】进行网点预存款，提交财务进行审核" style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-ok',position:'top',trackMouse:false,plain:false" href="javascript:void(0);" class="easyui-linkbutton easyui-tooltip" id="subbutton" name="subbutton" onclick="subTj()">确认存款</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
		</form>
		<!-- <div id="tb2">
			<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-print',plain:false" onclick="printCashBoxDetail()">打印</a>
		</div>
		<table id="dg2" title="柜员尾箱明细" style="width: 100%"></table> -->
	</div>
</body>
</html>
