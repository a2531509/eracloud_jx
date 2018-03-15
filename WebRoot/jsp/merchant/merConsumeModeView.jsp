<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="s" uri="/struts-tags"%>   
<script type="text/javascript">
	$(function() {
		
		$("#form").form({
			url :"/merchantRegister/merchantRegisterAction!saveConsumeMode.action",
			data: $('#form').serialize(),
			onSubmit : function(param) {
				parent.$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				
				var isValid = $(this).form('validate');
				if (!isValid) {
					parent.$.messager.progress('close');
				}
				return isValid;
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
<style>
	.textinput{
		height: 18px;
		width: 170px;
		line-height: 16px;
	    /*border-radius: 3px 3px 3px 3px;*/
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
	    transition: border 0.2s linear 0s, box-shadow 0.2s linear 0s;
	}
	
	textarea:focus, input[type="text"]:focus{
	    border-color: rgba(82, 168, 236, 0.8);
	    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset, 0 0 8px rgba(82, 168, 236, 0.6);
	    outline: 0 none;
		}
		table {
	    background-color: transparent;
	    border-collapse: collapse;
	    border-spacing: 0;
	    max-width: 100%;
	}

	fieldset {
	    border: 0 none;
	    margin: 0;
	    padding: 0;
	}
	legend {
	    -moz-border-bottom-colors: none;
	    -moz-border-left-colors: none;
	    -moz-border-right-colors: none;
	    -moz-border-top-colors: none;
	    border-color: #E5E5E5;
	    border-image: none;
	    border-style: none none solid;
	    border-width: 0 0 1px;
	    color: #999999;
	    line-height: 20px;
	    display: block;
	    margin-bottom: 10px;
	    padding: 0;
	    width: 100%;
	}
	input, textarea {
	    font-weight: normal;
	}
	table ,th,td{
		text-align:left;
		padding: 6px;
	}
</style>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: hidden;padding: 10px;">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户费率信息</legend>
				 <table>
					 <tr>
					 	<th>模式编号</th>
						<td>
							<input name="paySqn.modeId" id="modeId" value="${paySqn.modeId}"  class="textinput" type="text"/>
						</td>
					 	<th>模式名称</th>
						<td>
							<input name="paySqn.modeName" id="modeName" value="${paySqn.modeName}"  class="textinput" type="text"/>
						</td>
					</tr>
					<tr>
						<th>消费顺序</th>
						<td>
							<input name="paySqn.accSqn" id="accSqn" value="${paySqn.accSqn}"  class="textinput" type="text"/>
						</td>
						<th>退货顺序</th>
						<td>
							<input name="paySqn.reaccType" id="reaccType" value="${paySqn.reaccType}"  class="textinput" type="text"/>
						</td>
					</tr>
					<tr>
						<th>退货默认账户</th>
						<td>
							<input name="paySqn.reaccTypeBak" id="reaccTypeBak" value="${paySqn.reaccTypeBak}"  class="textinput"  type="text" />
						</td>
						<th>状态</th>
						<td>
							<input name="paySqn.modeState"  id="modeState" value="${paySqn.modeState}" class="easyui-combobox"   style="width:174px;" data-options="
								valueField: 'label',
								textField: 'value',
								value:'0',
								data: [{
									label: '0',
									value: '有效'
								},{
									label: '1',
									value: '无效'
								}]" />
						</td>
					</tr>
					<tr>
						<th>备注</th>
						<td>
							<input name="paySqn.note" id="note" value="${paySqn.note}"  class="textinput" type="text" />
						</td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>