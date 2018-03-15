<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>   
<script type="text/javascript">
	function setValue(vTxt) {
	    $('#merchantId').combobox('setValue', vTxt);
	 }
	function checkEndTime(){  
	    var startTime=$("#validDate").val();  
	    var start=new Date(startTime.replace("-", "/").replace("-", "/"));  
	    var endTime=timeStamp2String(new Date());  
	    var end=new Date(endTime.replace("-", "/").replace("-", "/"));  
	    if(start<=end){  
	        return false;  
	    }  
	    return true;  
	}  
	
	function timeStamp2String(time){
		var datetime = new Date();     
		datetime.setTime(time);     
		var year = datetime.getFullYear();     
		var month = datetime.getMonth() + 1 < 10 ? "0" + (datetime.getMonth() + 1) : datetime.getMonth() + 1;     
		var date = datetime.getDate() < 10 ? "0" + datetime.getDate() : datetime.getDate();     
		return year + "-" + month + "-" + date; 
	} 
	$(function() {
		$("#merchantId").combobox({
			 url:"merchantRegister/merchantRegisterAction!findALLMerchant.action",
            valueField: 'merchantId', 
            textField: 'merchantName',
            //注册事件
            onChange: function (newValue, oldValue) {
                if (newValue != null) {
                    var thisKey = encodeURIComponent($('#merchantId').combobox('getText')); //搜索词
                    var urlStr = "merchantRegister/merchantRegisterAction!getBizName.action?objStr=" + thisKey;
                    var v = $("#merchantId").combobox("reload", urlStr);
                }
            },
            
        });
		
		$("#form").form({
			url :"merchantRegister/merchantRegisterAction!saveRegistMer.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if(!checkEndTime()){
					parent.$.messager.show({
						title :'系统消息',
						msg : '您输入的生效日期不能在今天及今天之前！',
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
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload');
					parent.$.modalDialog.handler.dialog('close');
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户费率信息</legend>
				<input name="payFeeRate.feeRateId" id="feeRateId" value="${payFeeRate.feeRateId}"   type="hidden"/>
				<input name="payFeeRate.userId" id="userId" value="${payFeeRate.userId}"  type="hidden"/>
				<input name="payFeeRate.chkState" id="chkState" value="${payFeeRate.chkState}"  type="hidden"/>
				<input name="payFeeRate.chkDate" id="chkDate"  value="${payFeeRate.chkDate}"  type="hidden"/>
				<input name="payFeeRate.chkUserId" id="chkUserId" value="${payFeeRate.chkUserId}"  type="hidden"/>
				 <table class="tablegrid" style="width:100%">
					 <tr>
					 	<th class="tableleft">商户编号
						</th>
						<td class="tableright">
							<input name="payFeeRate.merchantId" id="merchantId01" readonly="readonly" value="${payFeeRate.merchantId}" onkeydown="autoCom()" onkeyup="autoCom()" class="textinput" type="text"/>
						</td>
						<th class="tableleft">商户名称
						</th>
						<td class="tableright">
							<input type="text" name="merchantName" id="merchantName01"  readonly="readonly" value="${merchantName}" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">交易名称</th>
						<td class="tableright">
							<input name="tr_Code"  id="tr_Code" value="${tr_Code}" class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '40201010',
									value: '终端_联机消费'
								},{
									label: '40101010',
									value: '终端_脱机消费'
								},{
									label: '40201051',
									value: '终端_联机消费退货'
								}]" />
						</td>
						<th class="tableleft" >费率状态</th>
						<td class="tableright">
							<input name="payFeeRate.feeState"  id="feeState" value="${payFeeRate.feeState}" class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '0',
									value: '在用'
								},{
									label: '1',
									value: '停用'
								}]" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">最大服务费</th>
						<td class="tableright">
							<input name="max" id="max" value="${max}"  class="textinput easyui-validatebox" type="text" />(元)
						</td>
						<th class="tableleft">最小服务费</th>
						<td class="tableright">
							<input name="min" id="min" value="${min}"  class="textinput easyui-validatebox" type="text" />(元)
						</td>
					</tr>
					<tr>
						<th class="tableleft">费率类型</th>
						<td class="tableright">
							<input name="payFeeRate.feeType"  id="feeType" value="${payFeeRate.feeType}" class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '1',
									value: '笔数费率'
								},{
									label: '2',
									value: '金额费率'
								}]" />
						</td>
						<th class="tableleft">费率</th>
						<td class="tableright">
							<input type="text" name="payFeeRate.feeRate" id="feeRate" value="${payFeeRate.feeRate}" class="textinput easyui-validatebox"/>
						</td>
						
					</tr>
					<tr>
						<th class="tableleft">收支标志</th>
						<td class="tableright">
							<input name="in_Out"  id="in_Out" value="${in_Out}" class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '1',
									value: '收'
								},{
									label: '2',
									value: '付'
								}]" />
						</td>
						<th class="tableleft" >生效日期</th>
						<td class="tableright">
							<input type="text" name="payFeeRate.begindate" id="begindate" value="${payFeeRate.begindate}" class="easyui-datebox easyui-validatebox" style="width: 174px;"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">是否采用分段费率</th>
						<td class="tableright">
							<input name="payFeeRate.haveSection"  id="haveSection" value="${payFeeRate.haveSection}" class="easyui-combobox" style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								data: [{
									label: '',
									value: '请选择'
								},{
									label: '0',
									value: '是'
								},{
									label: '1',
									value: '否'
								}]" />
						</td>
						<th class="tableleft">备注</th>
						<td class="tableright">
							<input name="payFeeRate.note" id="note" value="${payFeeRate.note}"  class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
				 </table>
			</fieldset>
				<s:if test='%{payFeeRate.haveSection== "0"}'>
					<div>
					<fieldset>
						<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>分段费率信息</legend>
						 <table class="tablegrid" style="width:100%">
						 	<s:if test='%{payFeeRate.feeType== "1"}'>
							 	<s:iterator value="list" id="item">
							 			<tr>
							 			<th class="tableleft">分段笔数
							 			</th>
							 			<td class="tableright"><input type="text" name="rateSection.id.sectionNum" id="sectionNum" value="${id.sectionNum}" class="textinput easyui-validatebox"/>笔</td>
							 			<th class="tableleft">大于分段的费率
							 			</th>
							 			<td class="tableright"><input type="text" name="rateSection.feeRate" id="feeRatese" value="${feeRate/100}" class="textinput easyui-validatebox"/>分/笔</td>
							 			</tr>
							 	</s:iterator>
						 	</s:if>
						 	<s:else>
							 	<s:iterator value="list" id="item">
							 			<tr>
							 			<th class="tableleft">分段金额
							 			</th>
							 			<td class="tableright"><input type="text" name="rateSection.id.sectionNum" id="sectionNum" value="${id.sectionNum}" class="textinput easyui-validatebox"/>元</td>
							 			<th class="tableleft">大于分段的费率
							 			</th>
							 			<td class="tableright"><input type="text" name="rateSection.feeRate" id="feeRatese" value="${feeRate/100}" class="textinput easyui-validatebox"/>%</td>
							 			</tr>
							 	</s:iterator>
						 	</s:else>
						 </table>
					</fieldset>
					</div>
				</s:if>
			</form>
	</div>
</div>
