<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:600}
</style>
<script type="text/javascript">
$(function(){
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
					<td class="tableright"><input name="co.coOrgName"  class="textinput" id="coOrgName2" type="text" readonly="readonly"  value="${co.coOrgName}" maxlength="128"/></td>
					<th class="tableleft">合作机构简称：</th>
					<td class="tableright"><input name="co.coAbbrName" id="coAbbrName2" type="text" readonly="readonly"  class="textinput easyui-validatebox" value="${co.coAbbrName}" data-options="required:true,missingMessage:'请输入合作机构简称',invalidMessage:'请输入合作机构简称'"/></td>
				 	<th class="tableleft">所属运营机构：</th>
					<td class="tableright"><input name="co.orgId" id="orgId2" type="text" readonly="readonly"  class="textinput easyui-validatebox" data-options="missingMessage:'请选择该合作机构的运营机构编号',invalidMessage:'请选择该合作机构的运营机构编号',required:true"/></td>
				 </tr>
				 <tr>
				 	<th class="tableleft">合作机构类型：</th>
					<td class="tableright" colspan="1"><input class="textinput easyui-validatebox" id="coOrgType2" name="co.coOrgType"  value="${co.coOrgType}" data-options="missingMessage:'请选择合作机构类型',invalidMessage:'请选择合作机构类型',required:true"/></td>
				    <th class="tableleft">上级合作机构编号：</th>
					<td class="tableright"><input name="co.topCoOrgId" id="topCoOrgId" type="text" readonly="readonly"  class="textinput easyui-validatebox" value="${co.topCoOrgId}" maxlength="15" onkeydown="addNumber(this)" onkeyup="addNumber(this)" data-options="missingMessage:'请输入该合作机构的上级合作机构编号',invalidMessage:'请输入该合作机构的上级合作机构编号',required:true"/></td>
					<th class="tableleft">上级合作机构名称：</th>
					<td class="tableright"><input name="topCoOrgName" id="topCoOrgName" type="text" readonly="readonly"  class="textinput easyui-validatebox" value="${co.topCoOrgId}"/></td>
				</tr>
				<tr>
					<th class="tableleft">对账数据主体：</th>
					<td class="tableright"><input id="checkType2" name="co.checkType" type="text" readonly="readonly"  class="textinput"/></td>
					<th class="tableleft">所属行业：</th><!-- （比如银行、连锁加盟商等） -->
					<td class="tableright"><input name="co.indusCode" id="indusCode2" type="text" readonly="readonly"  class="textinput"/></td>
					<th class="tableleft">结算方式：</th><!-- 自己单独结算还是上级结算，0是自己结算，1上级机构结算 -->
					<td class="tableright"><input name="co.stlType" id="stlType2" type="text" readonly="readonly"  class="textinput"/></td>
				 </tr>
				 <tr>
					<th class="tableleft">联系人：</th>
					<td class="tableright"><input name="co.contact" id="contact" type="text" readonly="readonly"  value="${co.contact}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人',invalidMessage:'请输入联系人'"/></td>
					<th class="tableleft">联系人手机号码：</th>
					<td class="tableright"><input name="co.conPhone" id="conPhone" type="text" readonly="readonly"  value="${co.conPhone}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人手机号码',invalidMessage:'请输入联系人手机号码'"/></td>
					<th class="tableleft">联系人证件类型：</th>
					<td class="tableright"><input name="co.conCertType" id="conCertType" type="text" readonly="readonly"  class="textinput"/></td>
				</tr>
			    <tr>
				 	<th class="tableleft">咨询电话：</th>
					<td class="tableright"><input name="co.hotline" id="hotline" type="text" readonly="readonly"  value="${co.hotline}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入咨询电话',invalidMessage:'请输入咨询电话'"/></td>
					<th class="tableleft">邮政编码：</th>
					<td class="tableright"><input name="co.postCode" id="postCode" type="text" readonly="readonly"  maxlength="6" value="${co.postCode}" class="textinput"/></td>
					<th class="tableleft">通讯地址：</th>
					<td class="tableright" colspan="1"><input name="co.address" id="address" type="text" readonly="readonly"  value="${co.address}" class="textinput" maxlength="128" /></td><!-- style="width:420px;" -->
				</tr>
				<tr>
					<th class="tableleft">联系人证件号码：</th>
					<td class="tableright"><input name="co.conCertNo" id="conCertNo" type="text" readonly="readonly"  value="${co.conCertNo}" class="textinput" onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"/></td>
					<th class="tableleft">合同号：</th>
					<td class="tableright"><input name="co.contactNo" id="contactNo" type="text" readonly="readonly"  value="${co.contactNo}" class="textinput"/></td>
					<th class="tableleft">合同类型：</th>
					<td class="tableright"><input name="co.contactType" id="contactType" type="text" readonly="readonly"  value="${co.contactType}" class="textinput"/></td>
				</tr>
				<tr>
			 	 	<td colspan="6"><h3 class="subtitle">合作机构法人信息</h3></td>
			 	</tr>
				<tr>
					<th class="tableleft">法人姓名：</th>
					<td class="tableright"><input name="co.legName" id="legName" type="text" readonly="readonly"  value="${co.legName}" class="textinput"/></td>
					<th class="tableleft">法人联系电话：</th>
					<td class="tableright"><input name="co.legPhone" id="legPhone" type="text" readonly="readonly"  value="${co.legPhone}" class="textinput"/></td>
					<th class="tableleft">法人证件类型：</th>
					<td class="tableright"><input name="co.legCertType" id="legCertType" type="text" readonly="readonly"   class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">法人证件号码：</th>
					<td class="tableright"><input name="co.legCertNo" id="legCertNo" type="text" readonly="readonly"  value="${co.legCertNo}" class="textinput" onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"/></td>
					<th class="tableleft">税务登记号：</th>
					<td class="tableright"><input name="co.taxRegNo" id="taxRegNo" type="text" readonly="readonly"  value="${co.taxRegNo}" class="textinput"/></td>
					<th class="tableleft">工商注册号：</th>
					<td class="tableright"><input name="co.bizRegNo" id="bizRegNo" type="text" readonly="readonly"  value="${co.taxRegNo}" class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">邮箱：</th>
					<td class="tableright"><input name="co.email" id="email" type="text" readonly="readonly"  value="${co.email}" class="textinput easyui-validatebox" data-options="missingMessage:'请输入联系邮箱地址',invalidMessage:'请输入联系邮箱地址',required:true,validType:'email'"/></td>
					
					<th class="tableleft">传真号码：</th>
					<td class="tableright" colspan="3"><input name="co.faxNum" id="faxNum" type="text" readonly="readonly"  value="${co.faxNum}" class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">开户银行：</th>
					<td class="tableright"><input name="co.bankId" id="bankId" type="text" readonly="readonly"  class="textinput"/></td>
					<th class="tableleft">银行账户名称：</th>
					<td class="tableright"><input name="co.bankAccName" id="bankAccName" type="text" readonly="readonly"  value="${co.bankAccName}" class="textinput"/></td>
					<th class="tableleft">银行帐号：</th>
					<td class="tableright"><input name="co.bankAccNo" id="bankAccNo" type="text" readonly="readonly"  value="${co.bankAccNo}" class="textinput"/></td>
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
