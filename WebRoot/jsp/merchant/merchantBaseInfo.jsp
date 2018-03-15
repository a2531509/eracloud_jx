<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix ="s" uri="/struts-tags"%>
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
		
		$("input").each(function(){
	        $(this).attr("readonly","readonly");
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
		
		$("#stlMode").combobox({
			 url:"commAction!findSysCodeByCodeType.action?codeType=STL_MODE",
             valueField: 'VALUE', 
             textField: 'TEXT',
             editable:false,
             panelHeight:"auto",
             loadFilter:function(data){
            	 return data.rows;
             }
		});
		
		$("#stlWay").combobox({
			url:"commAction!findSysCodeByCodeType.action?codeType=STL_WAY",
            valueField: 'VALUE', 
            textField: 'TEXT',
            editable:false,
            panelHeight:"auto",
            loadFilter:function(data){
           	 return data.rows;
            }
		});
		
		$("#stlWayRet").combobox({
			url:"commAction!findSysCodeByCodeType.action?codeType=STL_WAY",
            valueField: 'VALUE', 
            textField: 'TEXT',
            editable:false,
            panelHeight:"auto",
            loadFilter:function(data){
           	 return data.rows;
            }
		});
		
		$("#stlWayFee").combobox({
			url:"commAction!findSysCodeByCodeType.action?codeType=STL_WAY",
            valueField: 'VALUE', 
            textField: 'TEXT',
            editable:false,
            panelHeight:"auto",
            loadFilter:function(data){
           	 return data.rows;
            }
		});
	});
	
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: scroll;padding: 10px;" class="datagrid-toolbar">
		<form id="form1" method="post">
				<input name="merchant.customerId" id="customerId"  type="hidden"/>
				 <table class="tablegrid" style="width: 100%">
				 	<tr>
			 	 		<td colspan="6"><h3 class="subtitle">商户基本信息</h3></td>
			 	 	</tr>
					 <tr>
					    <th class="tableleft">商户名称</th>
						<td class="tableright"><input  name="merchant.merchantName" id="merchantName" value="${merchant.merchantName}"  class="textinput easyui-validatebox" type="text" required="required"/></td>
						<th class="tableleft">自己/上级结算</th>
						<td class="tableright">
							<select name="merchant.stlType"  id="stlType" value="${merchant.stlType}" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false"   style="width:174px;" validType="selectValueRequired['#stlType']"  >
									<option value="0">自己结算</option>
									<option value="1">上级结算</option>
							</select>
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
						<td class="tableright"><input name="merchant.bizRegNo" id="bizRegNo" value="${merchant.bizRegNo}"  class="textinput easyui-validatebox" type="text" required="required"/>
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
						<th class="tableleft">联系人证件类型</th>
						<td class="tableright"><input name="merchant.conCertType" id="conCertType" value="${merchant.conCertType}" class="easyui-combobox easyui-validatebox" type="text"/>
						</td>
						<th class="tableleft">联系人证件号码</th>
						<td class="tableright"><input name="merchant.conCertNo" id="conCertNo"  value="${merchant.conCertNo}"  class="textinput easyui-validatebox" validtype="idcard" type="text"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">联系人电话1</th>
						<td class="tableright"><input name="merchant.conPhone" id="conPhone" value="${merchant.conPhone}"  class="textinput easyui-validatebox" validtype="mobile" type="text" required="required"/>
						</td>
						<th class="tableleft">联系人电话2</th>
						<td class="tableright"><input name="merchant.conPhone2" id="conPhone2" value="${merchant.conPhone2}"  class="textinput easyui-validatebox" validtype="mobile" type="text" required="required"/>
						</td>
						<th class="tableleft">法人姓名</th>
						<td class="tableright"><input name="merchant.legName" value="${merchant.legName}" id="legName"  class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">法人证件类型</th>
						<td class="tableright"><input name="merchant.legCertType" value="${merchant.legCertType}" id="legCertType"  class="easyui-combobox easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">法人证件号码</th>
						<td class="tableright"><input name="merchant.legCertNo" value="${merchant.legCertNo}" id="legCertNo"  class="textinput easyui-validatebox" validtype="idcard" type="text" />
						</td>
						<th class="tableleft">法人手机号码</th>
						<td class="tableright"><input name="merchant.legPhone" value="${merchant.legPhone}" id="legPhone"  class="textinput easyui-validatebox" validtype="mobile" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">Email</th>
						<td class="tableright"><input name="merchant.email" value="${merchant.email}" id="email"  class="textinput easyui-validatebox"  validtype="email" type="text" /></td>
						<th class="tableleft">通讯地址</th>
						<td class="tableright"><input name="merchant.address" value="${merchant.address}" id="address"  class="textinput easyui-validatebox" type="text" /></td>
						<th class="tableleft">邮政编码</th>
						<td class="tableright"><input name="merchant.postCode" value="${merchant.postCode}" id="postCode"  class="textinput easyui-validatebox" type="text" /></td>
					</tr>
					<tr>
						<th class="tableleft">传真号码</th>
						<td class="tableright"><input name="merchant.faxNum" value="${merchant.faxNum}" id="faxNum"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">税务登记号</th>
						<td class="tableright"><input name="merchant.taxRegNo" value="${merchant.taxRegNo}" id="taxRegNo"  class="textinput easyui-validatebox" type="text" />
						</td>
						<th class="tableleft">发票邮寄地址</th>
						<td class="tableright"><input name="merchant.billAddr" value="${merchant.billAddr}" id="billAddr"  class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">所属区域</th>
						<td class="tableright"><input name="merchant.region" id="region" value="${merchant.region}" readonly="readonly"  maxlength="100" class="textinput" type="text" />
						</td>
						<td colspan="4"></td>
					</tr>
					<tr>
						<th class="tableleft">备注</th>
						<td class="tableright" colspan ="5"><input name="merchant.note" value="${merchant.note}" id="note"  class="textinput easyui-validatebox" type="text" style="width:89%;" />
					</tr>
				 </table>
			<div>
				<input name="mtype.id" id="id"  type="hidden"/>
				 <table class="tablegrid" style="width: 100%">
				   <tr>
			 	 		<td colspan="6"><h3 class="subtitle">结算参数信息</h3></td>
			 	 	</tr>
				 	<tr>
						<th>结算周期说明:</th>
						<td class="tableright" colspan ="3">
						<span style="color:red">结算方式为日结，结算周期为1表示：每天产生结算数据。<br/>
												结算方式为周结，结算周期为1表示：每周的星期一产生结算数据；结算周期为1|3|5;表示星期一、星期三、星期五产生结算数据。<br/>
												结算方式为月结，结算周期为1表示：每月1号产生结算数据，如果想每月最后一天产生结算数据结算周期写32。</span>
						</td>
					</tr>
					<tr>
					<th class="tableleft">结算模式:</th>
					<td ><input name="merchantStlMode.stlMode" value="${merchantStlMode.stlMode}" id="stlMode"  class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/></td>
					<th class="tableleft">生效日期</th>
					<td class="tableright" clospan="3">
						<input name="validDate" id="validDate" value="${merchantStlMode.id.validDate}" class="easyui-datebox" style="width:174px;" required="required"/>
					</td>
					<tr>
						<th class="tableleft">消费结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWay" value="${merchantStlMode.stlWay}" id="stlWay"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
   						<s:if test='%{merchantStlMode.stlWay== "2"}'> 
							<th class="tableleft">限额参数</th>
							<td class="tableright"><input name="merchantStlMode.stlLim" value="${merchantStlMode.stlLim}" id="stlLim"  class="textinput easyui-validatebox" type="text" />
							</td>
						</s:if>
						<s:else>
						<th class="tableleft">结算周期</th>
						<td class="tableright"><input name="merchantStlMode.stlDays" value="${merchantStlMode.stlDays}" id="stlDays"  class="textinput easyui-validatebox" type="text" />
						</td>
						</s:else>
					</tr>
					<tr>
						<th class="tableleft">退货结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWayRet" id="stlWayRet"  class="easyui-combobox easyui-validatebox"  value="${merchantStlMode.stlWayRet}"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
   						<s:if test='%{merchantStlMode.stlWayRet== "2"}'> 
						<th class="tableleft">限额参数</th>
						<td class="tableright"><input name="merchantStlMode.stlLimRet" id="stlLimRet" value="${merchantStlMode.stlLimRet}" class="textinput easyui-validatebox" type="text" />
						</td>
						</s:if>
						<s:else>
						<th class="tableleft">结算周期</th>
						<td class="tableright"><input name="merchantStlMode.stlDaysRet" id="stlDaysRet"  value="${merchantStlMode.stlDaysRet}"  class="textinput easyui-validatebox" type="text" />
						</td>
						</s:else>
					</tr>
					
					<tr>
						<th class="tableleft">服务费结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWayFee" id="stlWayFee" value="${merchantStlMode.stlWayFee}"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						</td>
						<s:if test='%{merchantStlMode.stlWayFee== "2"}'> 
						<th class="tableleft">限额参数</th>
						<td class="tableright"><input name="merchantStlMode.stlLimFee"  value="${merchantStlMode.stlLimFee}"  id="stlLimFee"  class="textinput easyui-validatebox" type="text" />
						</td>
						</s:if>
						<s:else>
						<th class="tableleft">结算周期</th>
						<td class="tableright"><input name="merchantStlMode.stlDaysFee" value="${merchantStlMode.stlDaysFee}"  id="stlDaysFee"  class="textinput easyui-validatebox" type="text" />
						</td>
						</s:else>
					</tr>
				 </table>
			</div>
			</form>
	</div>
</div>
