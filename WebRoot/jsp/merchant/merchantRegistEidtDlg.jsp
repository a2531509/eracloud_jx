<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
<style>
input::-ms-clear{display:none;}
</style>
<script type="text/javascript">
	function setValue(vTxt) {
	    $('#topMerchantId').combobox('setValue', vTxt);
	 }
	$(function() {
		$("#region").combobox({
			url:"commAction!findAllCustomCodeType.action",
			textField:"TEXT",
			valueField:"VALUE",
			onBeforeLoad:function(params){
				params.value="region_id";
				params.text="region_name";
				params.table="base_region";
				params.from=1;
				params.to=20;
			},
			loadFilter:function(data){
				return data.rows;
			}
		});

		$("#orgId").combobox({
			width:174,
			url:"sysOrgan/sysOrganAction!findAllOrgan.action",
			valueField:'orgId', 
			editable:false, //不可编辑状态
		    textField:'orgName',
		    onSelect:function(node){
		 		$("#orgId").val(node.text);
		 	}
		});
		
		createLocalDataSelect({
			id:"stlType",
			value:"0",
		    data:[
		        {value:"0",text:"自己结算"},
		        {value:"1",text:"上级结算"}
		    ]
		});
		createLocalDataSelect({
			id:"isSettleMonth",
			value:"",
		    data:[
				{value:"",text:"请选择"},
		        {value:"0",text:"月末强制结算"},
		        {value:"1",text:"月末不强制结算"}
		    ]
		});
		
		$("#bankId").combobox({
			width:174,
			url:"commAction!getAllBanks.action",
			valueField:'bank_id', 
			editable:false, //不可编辑状态
		    textField:'bank_name',
		    onSelect:function(node){
		 		$("#bankId").val(node.text);
		 	}
		});
		
		createSysCode("conCertType",{codeType:"CERT_TYPE",editable:false});
		createSysCode("legCertType",{codeType:"CERT_TYPE",editable:false});
		 $("#topMerchantId").combobox({
			 url:"merchantRegister/merchantRegisterAction!findALLMerchant.action",
             valueField: 'merchantId', 
             textField: 'merchantName',
             //注册事件
             onChange: function (newValue, oldValue) {
                 if (newValue != null) {
                     var thisKey = encodeURIComponent($('#topMerchantId').combobox('getText')); //搜索词
                     var urlStr = "merchantRegister/merchantRegisterAction!getBizName.action?objStr=" + thisKey;
                     var v = $("#topMerchantId").combobox("reload", urlStr);
                 }
             },
             
         });
		//初始话下拉上级行业下拉框
		$("#merchantType").combotree({
			width:174,
			url:"merchantType/merchantTypeAction!findMerchantTypeListTreeGrid.action",
			idFiled:'id',
		 	textFiled:'typeName',
		 	parentField:'parentId'
		});
		
		
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveRegistMer.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				
				if($("#orgId").combobox('getValue')==''){
					parent.$.messager.show({
						title :'系统消息',
						msg : '请输入所属机构！',
						timeout : 1000 * 3
	    			});
					return false;
				}
				
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
				
			},
			success:function(result) {
				parent.$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					$.modalDialog.handler.dialog('destroy');
					 $.modalDialog.handler = undefined;
					 $.messager.alert("系统消息",result.message,"info");
					 $dg.datagrid("reload");
				}else{
					parent.$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: scroll;padding: 10px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户信息编辑</legend>
				<input name="merchant.customerId" value="${merchant.customerId}" id="customerId"  type="hidden"/>
				<input name="merchant.merchantId" value="${merchant.merchantId}" id="merchantId"  type="hidden"/>
				<table class="tablegrid" style="width: 100%">
					 <tr>
					    <th class="tableleft">商户名称</th>
						<td><input name="merchant.merchantName" id="merchantName" value="${merchant.merchantName}"  class="textinput easyui-validatebox" type="text" required="required"/></td>
						<th class="tableleft">自己/上级结算</th>
						<td class="tableright">
							<input name="merchant.stlType"  id="stlType" value="${merchant.stlType}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false"   style="width:174px;" required="required"  >
							</input>
						</td>
						<th class="tableleft">商户类型</th>
						<td class="tableright"><input name="merchant.merchantType"  value="${merchant.merchantType}" class="textinput easyui-validatebox" id="merchantType"   data-options="panelHeight: 'auto',editable:false"  style="width:174px;" />
						</td>
					 </tr>
					 <tr>
						<th class="tableleft">所属机构</th>
						<td class="tableright">
							<input name="merchant.orgId" value="${merchant.orgId}"  class="easyui-combobox easyui-validatebox" id="orgId"   data-options="panelHeight: 'auto',editable:false"  style="width:174px;"/>
						</td>
						<th class="tableleft">工商注册号</th>
						<td class="tableright"><input name="merchant.bizRegNo" id="bizRegNo" value="${merchant.bizRegNo}"  class="textinput" type="text" />
						</td>
						<th class="tableleft">上级商户</th>
						<td class="tableright">
							<input name="merchant.topMerchantId"  value="${merchant.topMerchantId}" class="textinput easyui-validatebox" id="topMerchantId"   data-options="panelHeight: 'auto'"  style="width:174px;"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">行业代码</th>
						<td class="tableright"><input name="merchant.indusCode" value="${merchant.indusCode}" id="indusCode"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">合同号:</th>
						<td class="tableright"><input name="merchant.contactNo" id="contactNo" value="${merchant.contactNo}" class="textinput easyui-validatebox" type="text"/>
						</td>
						<th class="tableleft">合同类型:</th>
						<td class="tableright"><input name="merchant.contactType" id="contactType" value="${merchant.contactType}"   class="textinput easyui-validatebox" type="text"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">开户银行</th>
	                    <td class="tableright"><input name="merchant.bankBrch"  value="${merchant.bankBrch}" id="bankBrch"  class="textinput easyui-validatebox" type="text" />
	                    </td>	
						<th class="tableleft">银行账户名称</th>
						<td class="tableright"><input name="merchant.bankAccName"  value="${merchant.bankAccName}" id="bankAccName"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">银行账户账号</th>
	                    <td class="tableright"><input name="merchant.bankAccNo"  value="${merchant.bankAccNo}" id="bankAccNo"  class="textinput easyui-validatebox" type="text" required="required"/>
	                    </td>
					</tr>
					<tr>
						<th class="tableleft">联系人姓名</th>
						<td class="tableright"><input name="merchant.contact" id="contact"  value="${merchant.contact}" class="textinput easyui-validatebox" type="text" required="required"/>
						</td>
						<th class="tableleft">联系人证件号码</th>
						<td class="tableright"><input name="merchant.conCertNo" id="conCertNo"  value="${merchant.conCertNo}"  class="textinput easyui-validatebox" validtype="idcard" type="text"/>
						</td>
						<th class="tableleft">联系人电话1</th>
						<td class="tableright"><input name="merchant.conPhone" id="conPhone" value="${merchant.conPhone}"  class="textinput easyui-validatebox" type="text" required="required"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">联系人电话2</th>
						<td class="tableright"><input name="merchant.conPhone2" id="conPhone2" value="${merchant.conPhone2}"  class="textinput" maxlength="32" validtype="mobile" type="text"/>
						</td>
						<th class="tableleft">法人姓名</th>
						<td class="tableright"><input name="merchant.legName" value="${merchant.legName}" id="legName"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">法人证件类型</th>
						<td class="tableright"><input name="merchant.legCertType" value="${merchant.legCertType}" id="legCertType"  class="easyui-combobox easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">法人证件号码</th>
						<td class="tableright"><input name="merchant.legCertNo" value="${merchant.legCertNo}" id="legCertNo"  class="textinput easyui-validatebox" validtype="idcard" type="text" />
						</td>
						<th class="tableleft">法人手机号码</th>
						<td class="tableright"><input name="merchant.legPhone" value="${merchant.legPhone}" id="legPhone"  class="textinput easyui-validatebox" validtype="mobile" type="text" />
						</td>
						<th class="tableleft">Email</th>
						<td class="tableright"><input name="merchant.email" value="${merchant.email}" id="email"  class="textinput easyui-validatebox"  validtype="email" type="text" /></td>
					</tr>
					<tr>
						<th class="tableleft">通讯地址</th>
						<td class="tableright"><input name="merchant.address" value="${merchant.address}" id="address"  class="textinput easyui-validatebox" type="text" /></td>
						<th class="tableleft">邮政编码</th>
						<td class="tableright"><input name="merchant.postCode" value="${merchant.postCode}" id="postCode"  class="textinput easyui-validatebox" type="text" /></td>
						<th class="tableleft">传真号码</th>
						<td class="tableright"><input name="merchant.faxNum" value="${merchant.faxNum}" id="faxNum"  class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">税务登记号</th>
						<td class="tableright"><input name="merchant.taxRegNo" value="${merchant.taxRegNo}" id="taxRegNo"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">发票邮寄地址</th>
						<td class="tableright"><input name="merchant.billAddr" value="${merchant.billAddr}" id="billAddr"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">是否月末强制结算</th>
						<td class="tableright"><input name="merchant.isSettleMonth" id="isSettleMonth" value="${merchant.isSettleMonth}" maxlength="100" class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">所属区域</th>
						<td class="tableright"><input name="merchant.region" id="region"  maxlength="100" value="${merchant.region}" class="textinput" type="text" />
						</td>
						<td colspan="4"></td>
					</tr>
					<tr>
						<th class="tableleft">备注</th>
						<td class="tableright" colspan ="5" style="padding-right: 6%"><input name="merchant.note" value="${merchant.note}" id="note"  class="textinput easyui-validatebox" type="text" style="width:100%;" />
					</tr>
					<tr>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
