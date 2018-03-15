<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	
	$(function() {
	
		$("#form").form({
			url :"BasePsam/basePsamAction!updateReceivePsam.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#psamRreceiveDate").combobox("getValue")==""){
					$.messager.alert("系统消息","【领用日期】不能为空，请选择领用日期","error",function(){
						$("#psamRreceiveDate").combobox("showPanel");
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
					parent.reload;
					parent.$.modalDialog.openner.datagrid('reload',{
						queryType:'0'});
					parent.$.modalDialog.handler.dialog('close');
				}else{
					parent.$.messager.show({
						title :  "系统消息",
						msg : "保存失败",
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
<div class="easyui-layout" data-options="fit:true,border:false" style="background-color:rgb(245,245,245);">
	<div data-options="region:'center',border:false,fit:true" title="" style="overflow: hidden;padding:0px;background-color:rgb(245,245,245);">
		<form id="form" method="post">
			<fieldset>
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>PSAM卡领用</legend>
				<input name="basePsam.psamNo" id="endId" value="${basePsam.psamNo}"  type="hidden"/>
				 <table class="tablegrid" >
					<tr>
						<th style="width:76px">领用人</th>
						<td class="tableright"><input name="basePsam.psamRreceive"  value="${basePsam.psamRreceive}"style="width:174px;"  id="psamRreceive" required="required" maxlength="50"  class="textinput easyui-validatebox"  type="text" /></td>
						<th style="width:76px">领用日期</th>
						<td class="tableright"><input name="basePsam.psamRreceiveDate"  value="${basePsam.psamRreceiveDate}" id="psamRreceiveDate" style="width:174px;" class="easyui-datebox easyui-validatebox"  type="text" /></td>
					</tr>
				 </table>
			</fieldset>
			</form>
	</div>
</div>
