<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript">
	
	$(function() {
		
		//初始话下拉上级行业下拉框
		$("#parentId").combotree({
			width:174,
			url:"merchantType/merchantTypeAction!findMerchantTypeListTreeGrid.action",
			idFiled:'id',
		 	textFiled:'typeName',
		 	parentField:'parentId'
		});
		
		$("#form").form({
			url :"merchantType/merchantTypeAction!saveMerchantType.action",
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
			},
			success:function(result) {
				$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					$.modalDialog.openner.treegrid('reload');
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
				<legend><img src="extend/fromedit.png" style="margin-bottom: -3px;"/>商户类型编辑</legend>
				<input name="mtype.id" id="id"  type="hidden"/>
				 <table>
					 <tr>
					    <th>类型名称</th>
						<td><input name="mtype.typeName" id="typeName"  class="textinput easyui-validatebox" type="text" required="required"/></td>
						<th>等级</th>
						<td><select id="lev" class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false"  name="mtype.lev" style="width:174px;"  >
															<option value="">请选择</option>
															<option value="1">一级</option>
															<option value="2">二级</option>
															<option value="3">三级</option>
														</select> 
						</td>
					 </tr>
					 <tr>
					 	<th>序号</th>
						<td><input name="mtype.ordNo"  class="textinput easyui-validatebox" id="ordNo" type="text" validType="integer"/></td>
						<th>上级类型</th>
						<td><input name="mtype.parentId"  class="textinput easyui-validatebox" id="parentId"   data-options="panelHeight: 'auto',editable:false"  style="width:174px;"/></td>
					 </tr>
				 </table>
			</fieldset>
		</form>
	</div>
</div>
