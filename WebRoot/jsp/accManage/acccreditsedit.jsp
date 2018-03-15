<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<script type="text/javascript">
	var $cardinfo;
	$(function(){
		addNumberValidById("maxNum");
		if(dealNull("${defaultErrorMsg}") != ""){
			$.messager.alert("系统消息","${defaultErrorMsg}","error");
		}
		$("#minAmt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户的小额免密码支付的最大金额<br/><span style=\"color:red\">提示：勾选账户的消费金额小于该设置金额时可免输入密码进行支付。</span>",missingMessage:"请输入勾选账户的小额免密码支付的最大金额<br/><span style=\"color:red;\">提示：勾选账户的消费金额小于该设置金额时可免输入密码进行支付。</span>"});
		$("#amt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户的单笔最大可消费金额<br/><span style=\"color:red\">提示：该账户单笔消费金额大于该设置金额时，将拒绝此次交易。</span>",missingMessage:"请输入勾选账户的单笔最大可消费金额<br/><span style=\"color:red\">提示：该账户单笔消费金额大于该设置金额时，将拒绝此次交易。</span>"});
		$("#maxAmt").validatebox({required:true,validType:"email",invalidMessage:"请输入勾选账户单日累计最大可消费金额<br/><span style=\"color:red\">提示：勾选账户单日累计消费金额大于该本日累计消费限额时，则拒绝交易。</span>",missingMessage:"请输入勾选账户单日累计最大可消费金额<br/><span style=\"color:red;\">提示：勾选账户单日累计消费金额大于该本日累计消费限额时，则拒绝交易。</span>"});
		$("#minAmt").validatebox("validate");
		$("#amt").validatebox("validate");
		$("#maxAmt").validatebox("validate");
		createSysCode({
			id:"certType",
			codeType:"CERT_TYPE"
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE"
		});
		createSysCode({
			id:"accKind1",
			codeType:"ACC_KIND"
		});
		if("${bp.certType}" != ""){
			$("#certType").combobox("setValue","${bp.certType}");
			$("#certType").combobox("disable");
		}
		if("${limit.cardType}" != ""){
			$("#cardType").combobox("setValue","${limit.cardType}");
			$("#cardType").combobox("disable");
		}
		if("${limit.accKind}" != ""){
			$("#accKind1").combobox("setValue","${limit.accKind}");
			$("#accKind1").combobox("disable");
		}
	});
	function saveOrUpdateAccLimit(){
		if($("#amt").val() == ""){
			$.messager.alert("系统消息","请输入选账户的单笔消费最大限额！","error");
			return;
		}
		if($("#maxAmt").val() != ""){
			if(parseFloat($("#amt").val()) > parseFloat($("#maxAmt").val())){
				$.messager.confirm("系统消息","您确定要继续吗？<span style=\"color:red\">账户单日累计消费限额小于单笔消费最大限额，可能导致账户无法消费！</span>",function(r){
					if(r){
						saveSec();
					}
				});
				return;
			}
		}
		saveSec();
		/* $.messager.confirm("系统消息","您确定要修改该账户的限额信息吗？",function(r){
			if(r){
				$.post("/accountManager/accountManagerAction!saveOrUpdateAccLimit.action",
						$("#form").serialize() + "&queryType=1",
						function(data,status){
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							});
				},"json");
			}
		}); */
	}
	function saveSec(){
		$.messager.confirm("系统消息","您确定要修改该账户的限额信息吗？",function(r){
			if(r){
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("accountManager/accountManagerAction!saveOrUpdateAccLimit.action",
						$("#form").serialize() + "&queryType=1",
						function(data,status){
							$.messager.progress('close');
							$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function() {
								 if(data.status == "0"){
									 $dg.datagrid("reload");
									 $.modalDialog.handler.dialog('destroy');
									 $.modalDialog.handler = undefined;
								 }
							});
				},"json");
			}
		});
	}
	
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
	
</script>
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);margin-top:-4px;">
	<div data-options="region:'center',split:false,border:false,fit:true" style="height:300px; width:auto;text-align:center;border-top:none;">
		<div style="width:100%;">
			<form id="form" method="post">
				<input type="hidden" id="dealNo" name="limit.dealNo" value="${limit.dealNo}">
				 <h3 class="subtitle">个人卡片基本信息</h3>
				 <table class="tablegrid" style="width:100%;background-color:rgb(245,245,245)">
				 	<tr>
						<th class="tableleft" style="width:12%">客户编号：</th>
						<td class="tableright" style="width:12%"><input name="limit.customerId"  class="textinput" id="customerId" type="text" value="${bp.customerId}" disabled="disabled"/></td>
						<th class="tableleft" style="width:12%">姓名：</th>
						<td class="tableright" style="width:12%"><input name="bp.name"  class="textinput easyui-validatebox" id="name" type="text" value="${bp.name}" disabled="disabled"/></td>
						<th class="tableleft" style="width:12%">证件号码：</th>
						<td class="tableright" style="width:12%"><input name="bp.certNo" id="certNo" type="text" class="textinput easyui-validatebox" value="${bp.certNo }" disabled="disabled" /></td>
					 	<th class="tableleft" style="width:12%">证件类型：</th>
						<td class="tableright" style="width:16%"><input name="bp.certType" id="certType" type="text" class="textinput easyui-validatebox"></td>
					</tr>
					<tr>
						<th class="tableleft">卡号：</th>
						<td class="tableright"><input name="limit.cardNo"  class="textinput" id="cardNo" type="text" value="${limit.cardNo}" disabled="disabled"/></td>
						<th class="tableleft">卡类型：</th>
						<td class="tableright"><input name="limit.cardType"  class="textinput easyui-validatebox" id="cardType" type="text"/></td>
						<th class="tableleft">账户号：</th>
						<td class="tableright"><input name="limit.accNo" id="accNo" type="text" class="textinput easyui-validatebox" value="${limit.accNo}" disabled="disabled" /></td>
					 	<th class="tableleft">账户类型：</th>
						<td class="tableright"><input name="limit.accKind" id="accKind1" type="text" class="textinput easyui-validatebox"></td>
					</tr>
				</table>
				<h3 class="subtitle">账户限额信息</h3>
				<table  class="tablegrid" style="width:100%;background-color:rgb(245,245,245)">
				 	<tr>
				 		<th class="tableleft" style="width:12%">小额免密码支付：</th>
						<td class="tableright" style="width:12%"><input name="minAmt"  class="textinput" id="minAmt" type="text" value="${minAmt}" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
						<th class="tableleft" style="width:12%">单日消费最大笔数：</th>
						<td class="tableright" style="width:12%"><input name="maxNum" id="maxNum" type="text" class="textinput" value="${maxNum}"></td>
						<th class="tableleft" style="width:12%">单笔消费最大额度：</th>
						<td class="tableright" style="width:12%"><input name="amt"  class="textinput" id="amt" type="text" value="${amt}" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
						<th class="tableleft" style="width:12%">单日消费最大额度：</th>
						<td class="tableright" style="width:12%"><input name="maxAmt"  class="textinput" id="maxAmt" type="text" value="${maxAmt}" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/></td>
					</tr>
			  	</table>
		 	 </form>	
	 	</div>
	</div>
</div>