<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:600}
</style>
<script type="text/javascript">
$(function(){
	$("#coOrgName2").validatebox({
		required:true,
		validType:'email',
		missingMessage:"请输入合作机构名称<br/><span style=\"color:red;\">提示：合作机构名称最长128个字符.</span>",
		invalidMessage:"请输入合作机构名称<br/><span style=\"color:red;\">提示：合作机构名称最长128个字符.</span>"
	});
	$("#topCoOrgName").validatebox({
		required:true,
		validType:'email',
		missingMessage:"<span style=\"color:red;\">此输入框只供查询上级合作机构编号信息，该输入框信息不会被保存！</span>",
		invalidMessage:"<span style=\"color:red;\">此输入框只供查询上级合作机构编号信息，该输入框信息不会被保存！</span>"
	});
	$("#coAbbrName").validatebox({
		required:true,
		validType:'email',
		missingMessage:"请输入合作机构简称.",
		invalidMessage:"请输入合作机构简称."
	});
	$("#contactNo").validatebox({
		required:true,
		validType:'email',
		missingMessage:"请输入签约合同编号.",
		invalidMessage:"请输入签约合同编号."
	});
	$("#contactType").validatebox({
		required:true,
		validType:'email',
		missingMessage:"请输入签约合同类型.",
		invalidMessage:"请输入签约合同类型."
	});
	if("${defaultErrorMasg}" != ''){
		$.messager.alert("系统消息","${defaultErrorMasg}","error");
	}
	//所属运营机构
	getSearchInputData("orgId2","sys_organ","org_id","org_name","",function(){
		if("${co.orgId}" != ""){
			$("#orgId2").combobox("setValue","${co.orgId}");
		}
	});
	//联系人证件类型
	createCertType("conCertType");
	if("${co.conCertType}" != ""){
		$("#conCertType").combobox("setValue","${co.conCertType}");
	}else{
		$("#conCertType").combobox("setValue",'<s:property value="@com.erp.util.Constants@CERT_TYPE_SFZ"/>');
	}
	//法人的证件类型
	createCertType("legCertType");
	if("${co.legCertType}" != ""){
		$("#legCertType").combobox("setValue","${co.legCertType}");
	}else{
		$("#legCertType").combobox("setValue",'<s:property value="@com.erp.util.Constants@CERT_TYPE_SFZ"/>');
	}
	//是否下发安全码
	$("#safeCode").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"02",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'01',codeName:"是"},{codeValue:'02',codeName:"否"}],
		onChange:function(value){
				if(value == "02"){
					$(".ipAddress").hide();
					$(".portAddress").hide();
				}else if(value == "01"){
					$(".ipAddress").show();
					$(".portAddress").show();
				}
			}
	});
	if("${safeCode}" != ""){
		$("#safeCode").combobox("setValue","${safeCode}");
	}
	if("${ipAddress}" != ""){
		$("#ipAddress").combobox("setValue","${ipAddress}");
	}
	if("${portAddress}" != ""){
		$("#portAddress").combobox("setValue","${portAddress}");
	}
	
	//合作机构类型
	$("#coOrgType2").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"01",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'01',codeName:"合作机构"},{codeValue:'02',codeName:"商户合作机构"}]
	});
	if("${co.coOrgType}" != ""){
		$("#coOrgType2").combobox("setValue","${co.coOrgType}");
	}
	//对账类型
	$("#checkType2").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"2",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'1',codeName:"运营机构数据为主"},{codeValue:'2',codeName:"合作机构数据为主"},{codeValue:'3',codeName:"人工干预实际交易数据"}]
	});
	if("${co.checkType}" != ""){
		$("#checkType2").combobox("setValue","${co.checkType}");
	}
	$("#indusCode2").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"2",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'1',codeName:"银行"},{codeValue:'2',codeName:"连锁加盟"}]
	});
	if("${co.indusCode}" != ""){
		$("#indusCode2").combobox("setValue","${co.indusCode}");
	}
	$("#stlType2").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"0",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'0',codeName:'自己结算'},{codeValue:'1',codeName:"上级结构结算"}]
	});
	if("${co.stlType}" != ""){
		$("#stlType2").combobox("setValue","${co.stlType}");
	}
	$("#bankId").combobox({
		width:174,
		url:"commAction!getAllBanks.action",
		valueField:'bank_id', 
		editable:false,
	    textField:'bank_name',
	    onSelect:function(node){
	 		$("#bankId").val(node.text);
	 	}
	});
	if("${co.bankId}" != ""){
		$("#bankId").combobox("setValue","${co.bankId}");
	}
});
function saveBaseCoOrg(){
	var subtitle = "";
	if($("#queryType").val() == "0"){
		subtitle = "新增";
	}else if($("#queryType").val() == "1"){
		subtitle = "编辑";
	}else{
		$.messager.alert("系统消息","获取操作类型错误！","error");
		return;
	}
	if(dealNull($("#coOrgName2").val()) == ""){
		$.messager.alert("系统消息","请输入合作机构名称！","error",function(){
			$("#coOrgName2").focus();
		});
		return;
	}
	if(dealNull($("#safeCode").val()) == ""){
		$.messager.alert("系统消息","请选择是否下发安全码！","error",function(){
			$("#safeCode").combobox("showPanel");
		});
		return;
	}
	if(dealNull($("#coAbbrName2").val()) == ""){
		$.messager.alert("系统消息","请输入合作机构简称！","error",function(){
			$("#coAbbrName").focus();
		});
		return;
	}
	if(dealNull($("#orgId2").combobox("getValue")).length == 0){
		$.messager.alert("系统消息","请选择所属运营机构！","error",function(){
			$("#orgId2").combobox("showPanel");
		});
		return;
	}
	if(dealNull($("#coOrgType2").combobox("getValue")).length == 0){
		$.messager.alert("系统消息","请选择合作机构类型！","error",function(){
			$("#coOrgType2").combobox("showPanel");
		});
		return;
	}
	if(dealNull($("#checkType2").combobox("getValue")) == ""){
		$.messager.alert("系统消息","请选择对账主体类型！","error",function(){
			$("#checkType2").combobox("showPanel");
		});
		return;
	}
	if(dealNull($("#contact").val()) == ""){
		$.messager.alert("系统消息","请输入合作机构联系人！","error",function(){
			$("#contact").focus();
		});
		return;
	}
	if(dealNull($("#conPhone").val()) == ""){
		$.messager.alert("系统消息","请输入合作机构联系人电话号码！","error",function(){
			$("#conPhone").focus();
		});
		return;
	}
	if(dealNull($("#conCertNo").val()) == ""){
		$.messager.alert("系统消息","请输入合作机构联系人证件号码！","error",function(){
			$("#conCertNo").focus();
		});
		return;
	}
	if(dealNull($("#contactNo").val()) == ""){
		$.messager.alert("系统消息","请输入合同编号！","error",function(){
			$("#contactNo").focus();
		});
		return;
	}
	if(dealNull($("#contactType").val()) == ""){
		$.messager.alert("系统消息","请输入合同类型！","error",function(){
			$("#contactType").focus();
		});
		return;
	}
	$.messager.confirm("系统消息","您确定要" + subtitle + "该合作机构信息吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("cooperationAgencyManager/cooperationAgencyAction!saveOrUpdateBaseCoOrg.action",$("#form").serialize(),function(data,status){
				 $.messager.progress('close');
				 if(status == "success"){
					 $.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						 if(data.status == "0"){
							 $dg.datagrid("reload");
							 $.modalDialog.handler.dialog('destroy');
							 $.modalDialog.handler = undefined;
						 }
					 });
				 }else{
					 $.messager.alert("系统消息",subtitle + "合作机构信息出现错误，请重新进行操作！","error");
					 return;
				 }
			 },"json");
		 }
	});
}
//添加数字验证
function addNumber(elementId){
	var targetEle_ = elementId;
	if(typeof(targetEle_) == 'undefined'){
		return;
	}
	var oldOnkeyDownEvent = targetEle_.onkeydown;
	if(oldOnkeyDownEvent){
		targetEle_.onkeydown = function(){
			oldOnkeyDownEvent();
			var _reg = /^\d*$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = this.value.replace(/\D/g,"");
			}
		}
	}else{
		targetEle_.onkeydown = function(){
			var _reg = /^\d*$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = this.value.replace(/\D/g,"");
			}
		}
	}
	var oldOnkeyUpEvent = targetEle_.onkeyup;
	if(oldOnkeyUpEvent){
		targetEle_.onkeyup = function(){
			oldOnkeyUpEvent();
			var _reg = /^\d*$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = this.value.replace(/\D/g,"");
			}
		}
	}else{
		targetEle_.onkeyup = function(){
			var _reg = /^\d*$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = this.value.replace(/\D/g,"");
			}
		}
	}
	//onkeydown="addNumber(this)" onkeyup="addNumber(this)"
}
//证件号码校验
function addCertNo(elementId){
	var targetEle_ = elementId;
	if(typeof(targetEle_) == 'undefined'){
		return;
	}
	targetEle_.onkeydown = function(){
		if($("#conCertType").combobox("getValue") != "1"){
			return;
		}
		var _reg = /^\d{0,17}([0-9]?|[Xx]?)$/g;
		if(!_reg.test(this.value)){
			targetEle_.value = targetEle_.value.substring(0,targetEle_.value.length - 1);
		}
	}
	targetEle_.onkeyup = function(){
		if($("#conCertType").combobox("getValue") != "1"){
			return;
		}
		var _reg = /^\d{0,17}([0-9]?|[Xx]?)$/g;
		if(!_reg.test(this.value)){
			targetEle_.value = targetEle_.value.substring(0,targetEle_.value.length - 1);
		}
	}
	//onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"
}
function autoCom2(){
	if($("#topCoOrgId").val() == ""){
		$("#topCoOrgName").val("");
	}
	$("#topCoOrgId").autocomplete({
		position: {my:"left top",at:"left bottom",of:"#topCoOrgId"},
	    source: function(request,response){
		    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#topCoOrgId").val(),"queryType":"1","co.customerId":$("#customerId").val()},function(data){
		    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
		    },'json');
	    },
	    select: function(event,ui){
	      	$('#topCoOrgId').val(ui.item.label);
	        $('#topCoOrgName').val(ui.item.value);
	        return false;
	    },
      	focus:function(event,ui){
	        return false;
      	}
    }); 
}
function autoComByName2(){
	if($("#topCoOrgName").val() == ""){
		$("#topCoOrgId").val("");
	}
	$("#topCoOrgName").autocomplete({
	    source:function(request,response){
	        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#topCoOrgName").val(),"queryType":"0","co.customerId":$("#customerId").val()},function(data){
	            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
	        },'json');
	    },
	    select: function(event,ui){
	    	$('#topCoOrgId').val(ui.item.value);
	        $('#topCoOrgName').val(ui.item.label);
	        return false;
	    },
	    focus: function(event,ui){
	        return false;
	    }
    }); 
}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" style="overflow:auto;padding:0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			 <s:hidden name="co.customerId" id="customerId"></s:hidden>
			 <s:hidden name="queryType" id="queryType"></s:hidden>
			 <table class="tablegrid" style="width:100%">
			 <tbody>
			 	 <tr>
			 	 	<td colspan="6"><h3 class="subtitle">合作机构基本信息</h3></td>
			 	 </tr>
			 	 
				 <tr>
					<th class="tableleft">合作机构名称：</th>
					<td class="tableright"><input name="co.coOrgName"  class="textinput" id="coOrgName2" type="text" value="${co.coOrgName}" maxlength="128"/></td>
					<th class="tableleft">合作机构简称：</th>
					<td class="tableright"><input name="co.coAbbrName" id="coAbbrName2" type="text" class="textinput easyui-validatebox" value="${co.coAbbrName}" data-options="required:true,missingMessage:'请输入合作机构简称',invalidMessage:'请输入合作机构简称'"/></td>
				 	<th class="tableleft">所属运营机构：</th>
					<td class="tableright"><input name="co.orgId" id="orgId2" type="text" class="textinput easyui-validatebox" data-options="missingMessage:'请选择该合作机构的运营机构编号',invalidMessage:'请选择该合作机构的运营机构编号',required:true"/></td>
				 </tr>
				 <tr>
				 	<th class="tableleft">合作机构类型：</th>
					<td class="tableright" colspan="1"><input class="textinput easyui-validatebox" id="coOrgType2" name="co.coOrgType"  value="${co.coOrgType}" data-options="missingMessage:'请选择合作机构类型',invalidMessage:'请选择合作机构类型',required:true"/></td>
				    <th class="tableleft">上级合作机构编号：</th>
					<td class="tableright"><input name="co.topCoOrgId" id="topCoOrgId" type="text" class="textinput easyui-validatebox" value="${co.topCoOrgId}" maxlength="15" onkeydown="autoCom2();" onkeyup="autoCom2();" data-options="missingMessage:'请输入该合作机构的上级合作机构编号',invalidMessage:'请输入该合作机构的上级合作机构编号',required:true"/></td>
					<th class="tableleft">上级合作机构名称：</th>
					<td class="tableright"><input name="topCoOrgName" id="topCoOrgName" type="text" class="textinput easyui-validatebox" value="${topCoOrgName}" onkeydown="autoComByName2()" onkeyup="autoComByName2()"/></td>
				</tr>
				<tr>
					<th class="tableleft">对账数据主体：</th>
					<td class="tableright"><input id="checkType2" name="co.checkType" type="text" class="textinput"/></td>
					<th class="tableleft">所属行业：</th>
					<td class="tableright"><input name="co.indusCode" id="indusCode2" type="text" class="textinput"/></td>
					<th class="tableleft">结算方式：</th>
					<td class="tableright"><input name="co.stlType" id="stlType2" type="text" class="textinput"/></td>
				 </tr>
				 <tr>
					<th class="tableleft">联系人：</th>
					<td class="tableright"><input name="co.contact" id="contact" type="text" value="${co.contact}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人',invalidMessage:'请输入联系人'"/></td>
					<th class="tableleft">联系人手机号码：</th>
					<td class="tableright"><input name="co.conPhone" id="conPhone" type="text" value="${co.conPhone}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人手机号码',invalidMessage:'请输入联系人手机号码'"/></td>
					<th class="tableleft">联系人证件类型：</th>
					<td class="tableright"><input name="co.conCertType" id="conCertType" type="text" class="textinput"/></td>
				</tr>
			    <tr>
				 	<th class="tableleft">咨询电话：</th>
					<td class="tableright"><input name="co.hotline" id="hotline" type="text" value="${co.hotline}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入咨询电话',invalidMessage:'请输入咨询电话'"/></td>
					<th class="tableleft">邮政编码：</th>
					<td class="tableright"><input name="co.postCode" id="postCode" type="text" maxlength="6" value="${co.postCode}" class="textinput"/></td>
					<th class="tableleft">通讯地址：</th>
					<td class="tableright" colspan="1"><input name="co.address" id="address" type="text" value="${co.address}" class="textinput" maxlength="128" /></td><!-- style="width:420px;" -->
				</tr>
				<tr>
					<th class="tableleft">联系人证件号码：</th>
					<td class="tableright"><input name="co.conCertNo" id="conCertNo" type="text" value="${co.conCertNo}" class="textinput" onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"/></td>
					<th class="tableleft">合同号：</th>
					<td class="tableright"><input name="co.contactNo" id="contactNo" type="text" value="${co.contactNo}" class="textinput"/></td>
					<th class="tableleft">合同类型：</th>
					<td class="tableright"><input name="co.contactType" id="contactType" type="text" value="${co.contactType}" class="textinput"/></td>
				</tr>
				<tr>
			 	 	<th class="tableleft">是否下发安全码：</th>
			 	 	<td class="tableright" colspan="1"><input class="textinput easyui-validatebox" id="safeCode" name="safeCode"  value="${safeCode}" data-options="missingMessage:'是否下发安全码',invalidMessage:'是否下发安全码',required:true"/></td>
			 	 	<th class="tableleft ipAddress" style="display:none">IP地址：</th>
					<td class="tableright ipAddress" style="display:none"><input name="ipAddress" id="ipAddress" type="text" value="${ms.ipAddress}" class="textinput"/></td>
					<th class="tableleft portAddress" style="display:none">端口：</th>
					<td class="tableright portAddress" style="display:none"><input name="portAddress" id="portAddress" type="text" value="${ms.portAddress}" class="textinput"/></td>
			 	 </tr>	
				<tr>
			 	 	<td colspan="6"><h3 class="subtitle">合作机构法人信息</h3></td>
			 	</tr>
				<tr>
					<th class="tableleft">法人姓名：</th>
					<td class="tableright"><input name="co.legName" id="legName" type="text" value="${co.legName}" class="textinput"/></td>
					<th class="tableleft">法人联系电话：</th>
					<td class="tableright"><input name="co.legPhone" id="legPhone" type="text" value="${co.legPhone}" class="textinput"/></td>
					<th class="tableleft">法人证件类型：</th>
					<td class="tableright"><input name="co.legCertType" id="legCertType" type="text"  class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">法人证件号码：</th>
					<td class="tableright"><input name="co.legCertNo" id="legCertNo" type="text" value="${co.legCertNo}" class="textinput" onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"/></td>
					<th class="tableleft">税务登记号：</th>
					<td class="tableright"><input name="co.taxRegNo" id="taxRegNo" type="text" value="${co.taxRegNo}" class="textinput"/></td>
					<th class="tableleft">工商注册号：</th>
					<td class="tableright"><input name="co.bizRegNo" id="bizRegNo" type="text" value="${co.taxRegNo}" class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">邮箱：</th>
					<td class="tableright"><input name="co.email" id="email" type="text" value="${co.email}" class="textinput easyui-validatebox" data-options="missingMessage:'请输入联系邮箱地址',invalidMessage:'请输入联系邮箱地址',required:true,validType:'email'"/></td>
					
					<th class="tableleft">传真号码：</th>
					<td class="tableright" colspan="3"><input name="co.faxNum" id="faxNum" type="text" value="${co.faxNum}" class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">开户银行：</th>
					<td class="tableright"><input name="co.bankId" id="bankId" type="text" class="textinput"/></td>
					<th class="tableleft">银行账户名称：</th>
					<td class="tableright"><input name="co.bankAccName" id="bankAccName" type="text" value="${co.bankAccName}" class="textinput"/></td>
					<th class="tableleft">银行帐号：</th>
					<td class="tableright"><input name="co.bankAccNo" id="bankAccNo" type="text" value="${co.bankAccNo}" class="textinput"/></td>
				</tr>
				<tr>
			 	 	<td colspan="6"><h3 class="subtitle">合作机构通信信息</h3></td>
			 	</tr>
				
				<tr>
					<th class="tableleft">备注：</th>
					<td class="tableright" colspan="5">
						<textarea class="textinput" id="note" name="co.note"  style="width:900px;height:60px;overflow:hidden;">${co.note}</textarea>
					</td>
				</tr>
			</tbody>
		    </table>
		</form>
	</div>
</div>
