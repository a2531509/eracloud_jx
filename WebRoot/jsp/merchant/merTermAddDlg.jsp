<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<style type="text/css">
	.readonly{
		background: rgb(235, 235, 228)
	}
</style>
<script type="text/javascript">
	function setValue(vTxt) {
	    $('#ownId').combobox('setValue', vTxt);
	 }
	$(function() {
		$("#endSrc").combobox({
			panelHeight: 'auto',
			editable:false,
			valueField: 'label',
			textField: 'value',
			data: [{
				label: '',
				value: '请选择'
			},{
				label: '1',
				value: '自购'
			},{
				label: '2',
				value: '租用'
			}]
		});
		
		$("#endType").combobox({
			panelHeight: 'auto',editable:false,
			valueField: 'label',
			textField: 'value',
			data: [{
				label: '',
				value: '请选择'
			},{
				label: '1',
				value: '人工'
			},{
				label: '2',
				value: '自助'
			},{
				label: '9',
				value: '虚拟终端'
			}]
		});
		
		var type = $("#type").val();
		
		if(type === "0"){
			$("#endId2").addClass("easyui-validatebox");
			$("#endId2").removeClass("readonly");
			$("#endId2").removeAttr("readonly");
		} else {
			$("#endId2").removeClass("easyui-validatebox");
			$("#endId2").addClass("readonly");
			$("#endId2").attr("readonly", "readonly");
		}
		
		addNumberValidById("endId2");
		
		$("#ownId").combobox({
			url:"merchantRegister/merchantRegisterAction!getBizName.action",
          	valueField: 'merchantId', 
        	textField: 'merchantName',
        	mode:"remote",
        	onBeforeLoad:function(params){
        		if(params && params["q"]){
        			params["objStr"] = params["q"];
        		}
        	},
        	loadFilter:function(data){
        		if(data){
        			data.unshift({merchantId:"", merchantName:"请选择"});
        		}
        		
        		return data;
        	}
       });
	
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveTerm.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					$.messager.progress('close');
				}
				return isValid;
				//验证输入框的值
			},
			success:function(result) {
				$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					parent.reload;
					parent.reload;
					$.modalDialog.openner.datagrid('reload',{
						queryType:'0'});
					$.modalDialog.handler.dialog('close');
				}else{
					$.messager.show({
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
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<fieldset>
				<input name="tagEnd.endDealNo" id="endDealNo" value="${tagEnd.endDealNo}"  type="hidden"/>
				<input name="tagEnd.dealBatchNo" value="${tagEnd.dealBatchNo}" id="dealBatchNo"  type="hidden"/>
				<input name="tagEnd.lastTime" value="${tagEnd.lastTime}" id="lastTime"  type="hidden"/>
				<input name="tagEnd.loginTime" value="${tagEnd.loginTime}" id="loginTime"  type="hidden"/>
				<input name="tagEnd.loginFlag" value="${tagEnd.loginFlag}" id="loginFlag"  type="hidden"/>
				<input name="tagEnd.orgId" value="${tagEnd.orgId}" id="orgId"  type="hidden"/>
				<input name="type" value="${type}" id="type" type="hidden"/>
				<table class="tablegrid">
				 	<tr>
						<td colspan="6">
							<h3 class="subtitle">终端信息</h3>
						</td>
					</tr>
					 <tr>
					    <th class="tableleft">终端编号</th>
						<td class="tableright">
							<input name="tagEnd.endId"  id="endId2" value="${tagEnd.endId}" class="textinput easyui-validatebox" maxlength="8" type="text" required="required"/></td>
					 	<th class="tableleft">终端名称</th>
						<td class="tableright">
							<input name="tagEnd.endName"  id="endName" value="${tagEnd.endName}" class="textinput easyui-validatebox" maxlength="30" type="text" required="required"/></td>
						<th class="tableleft">设备号</th>
						<td class="tableright">
							<input name="tagEnd.devNo"  value="${tagEnd.devNo}" class="textinput" id="devNo"  maxlength="30"/>
						</td>
					 </tr>
					 <tr>
						<th class="tableleft">终端型号</th>
						<td class="tableright">
							<input name="tagEnd.model"  value="${tagEnd.model}" class="textinput" id="model"  maxlength="64" data-options="panelHeight: 'auto',editable:false"  />
						</td>
						<th class="tableleft">终端来源</th>
						<td class="tableright">
							<input name="tagEnd.endSrc"  id="endSrc" value="${tagEnd.endSrc}" class="textinput"/>
						</td>
						<th class="tableleft">终端用途</th>
						<td class="tableright">
							<input name="tagEnd.usage"  id="usage" value="${tagEnd.usage}" class="easyui-combobox textinput" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '1',
													value: '支付终端'
												},{
													label: '2',
													value: '非支付终端'
												}]"     />
						</td>
					 </tr>
					 <tr>
						<th class="tableleft">终端类型</th>
						<td class="tableright">
							<input name="tagEnd.endType" id="endType" value="${tagEnd.endType}" class="textinput"/>
						</td>
						<th class="tableleft">权限角色编号</th>
						<td class="tableright">
							<input name="tagEnd.roleId"  id="roleId" value="${tagEnd.roleId}" class="easyui-combobox textinput" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '0',
													value: '一般柜员'
												},{
													label: '1',
													value: '网点主管'
												},{
													label: '2',
													value: '网点及子网点'
												},{
													label: '3',
													value: '当前机构'
												},{
													label: '4',
													value: '机构及子机构'
												},{
													label: '5',
													value: '所有数据权限'
												}]"    />
						</td>
						<th class="tableleft">所属类型</th>
						<td class="tableright">
							<input name="tagEnd.acptType"  id="acptType" value="${tagEnd.acptType}" class="easyui-combobox textinput" data-options="panelHeight: 'auto',editable:false,
												valueField: 'label',
												textField: 'value',
												data: [{
													label: '',
													value: '请选择'
												},{
													label: '0',
													value: '商户'
												},{
													label: '1',
													value: '网点'
												}]"    />
						</td>
					</tr>
					<tr>
						<th class="tableleft">人社PSAM编号</th>
						<td class="tableright">
							<input name="tagEnd.psamNo"  value="${tagEnd.psamNo}" id="psamNo" maxlength="20" class="textinput" />
						</td>
						<th class="tableleft">住建PSAM编号</th>
						<td class="tableright">
							<input name="tagEnd.psamNo2"  value="${tagEnd.psamNo2}" id="psamNo2" maxlength="20" class="textinput" />
						</td>
						<th class="tableleft">SIM卡号</th>
						<td class="tableright">
							<input name="tagEnd.simNo" value="${tagEnd.simNo}" id="simNo" maxlength="30"  class="textinput"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">所属商户</th>
						<td class="tableright">
							<input name="tagEnd.ownId" value="${tagEnd.ownId}" id="ownId"   class="easyui-combobox textinput" />
						</td>
						<th class="tableleft">联系人</th>
						<td class="tableright">
							<input name="tagEnd.mngUserId"  value="${tagEnd.mngUserId}" id="mngUserId" maxlength="10" class="textinput" type="text"/>
						</td>
						<th class="tableleft">联系电话</th>
						<td class="tableright">
							<input name="tagEnd.mngUserPhone" value="${tagEnd.mngUserPhone}" id="mngUserPhone"  class="textinput"/>
					</tr>
					<tr>
						<th class="tableleft">安装位置</th>
						<td class="tableright">
							<input name="tagEnd.insLocation" value="${tagEnd.insLocation}" id="insLocation"  class="textinput easyui-validatebox" type="text" required="required"/>
						<th class="tableleft">安装日期</th>
						<td class="tableright">
							<input name="tagEnd.insDate" value="${tagEnd.insDate}" id="insDate"   class="textinput easyui-datebox" type="text" required="required"/>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">厂家信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">生产厂家</th>
						<td class="tableright">
							<input name="tagEnd.producer"  value="${tagEnd.producer}" id="producer" maxlength="64" class="textinput" type="text"/>
						</td>
						<th class="tableleft">出厂日期</th>
						<td class="tableright">
							<input name="tagEnd.standbyDate" value="${tagEnd.standbyDate}" id="standbyDate"  class="easyui-datebox textinput" type="text"  />
						</td>
						<th class="tableleft">合同号</th>
	                    <td class="tableright">
	                    	<input name="tagEnd.contractNo" value="${tagEnd.contractNo}" id="contractNo" maxlength="64" class="textinput" type="text"/>
	                    </td>
					</tr>
					<tr>
						<th class="tableleft">采购日期</th>
	                    <td class="tableright">
	                    	<input name="tagEnd.buyDate" value="${tagEnd.buyDate}" id="buyDate"  class="easyui-datebox textinput" type="text"  />
	                    </td>			
						<th class="tableleft">采购单价</th>
						<td class="tableright">
							<input name="tagEnd.price"  value="${tagEnd.price}" id="price" maxlength="12" class="textinput" type="text" />
						</td>
						<th class="tableleft">保修厂家</th>
						<td class="tableright">
							<input name="tagEnd.maintCorp"  value="${tagEnd.maintCorp}" style="width:170px;" maxlength="64" id="maintCorp"  class="textinput" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">厂家电话</th>
						<td class="tableright">
							<input name="tagEnd.maintPhone"  value="${tagEnd.maintPhone}"style="width:172px;"  id="maintPhone" maxlength="32" class="textinput"  type="text" />
						</td>
						<th class="tableleft">保修截止日期</th>
						<td class="tableright">
							<input name="tagEnd.maintPeriod"  value="${tagEnd.maintPeriod}" id="maintPeriod"  class="easyui-datebox textinput"  type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">备注</th>
						<td class="tableright" colspan="5">
							<input name="tagEnd.note"  value="${tagEnd.note}" id="note" style="width:713px;" class="textinput" />
						</td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
