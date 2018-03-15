<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<style>
	.tablegrid th{font-weight:600}
</style>
<script type="text/javascript">
	$(function() {
		$("#isLkBrch").combobox({
			textField:"text",
			valueField:"value",
			panelHeight:"auto",
			editable:false,
			data:[
				{text:"请选择", value:""},
				{text:"是", value:"0"},
				{text:"否", value:"1"}
			]
		})
		$("#isLkBrch2").combobox({
			textField:"text",
			valueField:"value",
			panelHeight:"auto",
			editable:false,
			data:[
				{text:"请选择", value:""},
				{text:"是", value:"0"},
				{text:"否", value:"1"}
			]
		})
		createRegionSelect("regionId","townId","commId");
		createSys_Org(
			{id:"orgId"},
			{id:"pid"}
		);
		$("#iconCls").combobox({
			editable:false,
			data:$.iconData,
			formatter: function(v){
				return $.formatString('<span class="{0}" style="display:inline-block;vertical-align:middle;width:16px;height:16px;"></span>{1}', v.value, v.value);
			}
		});	
		createLocalDataSelect({
			id:"brchType",
			value:"1",
			data:[
			   	{value:"1",text:"自有网点"},
			   	{value:"2",text:"合作网点"},
			   	{value:"3",text:"代理网点"}
			],
			onSelect:function(r){
				
			}
		});
		$("#assistantManager").combobox({
			onSelect:function(node){
				if(node.value == "1"){
					$("#pid").attr("readonly","readonly");
					$("#pid").combotree("setValues","");
				}else{
					$("#pid").combotree("readonly", false);
				}
			}
		});
		createCustomSelect({
			id:"bankIds",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0'",
			orderby:"bank_id asc",
			from:1,
			to:20
		});
		$("#form").form({
			url:"orgz/SysBranchAction!persistenceSysBranch.action",
			onSubmit:function() {
				if(dealNull($("#orgId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择网点所属机构！","error",function(){
						$("#orgId").combobox("showPanel");
					});
					return false;
				}
				if(dealNull($("#assistantManager").combobox("getValue"))==""){
					$.messager.alert("系统消息","请选择网点级别！","error",function(){
						$("#assistantManager").combobox("showPanel");
					});
					return false;
				}
				if(dealNull($("#assistantManager").combobox("getValue")) != "1"){
					if(dealNull($("#pid").combotree("getValue")) == ""){
						$.messager.alert("系统消息","请选择上级网点！","error",function(){
							$("#pid").combotree("showPanel");
						});
						return false;
					}
				}
				if(dealNull($("#regionId").combobox("getValue")) == ""){
					jAlert("请选择网点所属区域！","error",function(){
						$("#regionId").combobox("showPanel");
					});
					return false;
				}
				$.messager.progress({text:"数据处理中，请稍后...."});
				var isValid = $(this).form("validate");
				if (!isValid) {
					$.messager.progress("close");
				}
				return isValid;
			},
			success:function(result) {
				$.messager.progress("close");
				result = $.parseJSON(result);
				if (result.status) {
					$.modalDialog.openner.treegrid("reload");
					jAlert(result.message,"info",function(){
						$.modalDialog.handler.dialog("close");
					});
				}else{
					jAlert(result.message,"error");
				}
			}
		});
	});
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow:hidden;" class="datagrid-toolbar">
		<form id="form" method="post">
			<input name="sysBranchId" id="sysBranchId"  type="hidden"/>
			<input name="created" id="created"  type="hidden"/>
			<input name="creater" id="creater"  type="hidden"/>
			<input name="status" id="status"  type="hidden"/>
			<table class="tablegrid" style="width:100%">
				<tr>
				    <th class="tableleft" style="width:12%">网点名称：</th>
					<td class="tableright"><input name="fullName" id="fullName" placeholder="请输入网点名称" class="textinput easyui-validatebox" type="text" data-options="required:true" style="border-color: #ffa8a8;"/></td>
					<th class="tableleft">简称：</th>
					<td class="tableright"><input id="shortName" name="shortName" type="text" class="textinput easyui-validatebox"/></td>
					<th class="tableleft">组织图标：</th>
					<td class="tableright"><input id=iconCls name="iconCls" class="textinput"/></td>
				</tr>
			    <tr>
					<th class="tableleft">网点编码：</th>
					<td class="tableright"><input name="brchId" id="brchId" type="text" placeholder="（4位机构号+4位网点号）" class="textinput easyui-validatebox" data-options="required:true, validType:'length[8, 8]'"  style="border-color: #ffa8a8;" maxlength="8" onkeypress = 'return /^\d$/.test(String.fromCharCode(event.keyCode||event.keycode||event.which))'
                        oninput= 'this.value = this.value.replace(/\D+/g, "")'
                        onpropertychange='if(!/\D+/.test(this.value)) {return;};this.value=this.value.replace(/\D+/g, "")'
                        onblur = 'this.value = this.value.replace(/\D+/g, "")'/></td>
					<th class="tableleft">网点类型：</th>
					<td class="tableright"><input id="brchType" name="brchType" type="text"></td>
					<th class="tableleft">网点级别：</th>
					<td class="tableright">
						<select id="assistantManager" class="easyui-combobox easyui-validatebox"  style="width:178px;" name="assistantManager" data-options="editable:true" validType="selectValueRequired['#assistantManager']" >
							<option value="">请选择</option>
							<option value="1">一级网点</option>
							<option value="2">二级网点</option>
							<option value="3">三级网点</option>
							<option value="4">四级网点</option>
							<option value="5">五级网点</option>
							<option value="6">六级网点</option>
						</select>
					</td>
			    </tr>
				<tr>
					<th class="tableleft">所属机构：</th>
					<td class="tableright"><input name="orgId" id="orgId" type="text" class="textinput"/></td>
				    <th class="tableleft">上层网点：</th>
					<td class="tableright"><input id="pid" name="pid" class="textinput" type="text"/></td>
					<th class="tableleft">电话：</th>
					<td class="tableright"><input id="tel" name="tel" type="text" class="textinput easyui-validatebox"/></td>
				</tr>
				<tr>
					<th class="tableleft">所属区域：</th>
					<td class="tableright"><input name="regionId"  class="textinput" id="regionId"  type="text" /></td>
					<th class="tableleft">乡镇（街道）：</th>
					<td class="tableright"><input name="townId"  class="textinput" id="townId"  type="text" /></td>
					<th class="tableleft">社区（村）：</th>
					<td class="tableright"><input name="commId"  class="textinput" id="commId" type="text"  /></td>
				</tr>
				<tr>
				 	<th class="tableleft">所属银行：</th>
					<td class="tableright"><input id="bankIds" name="bankIds" type="text" class="textinput"/></td>
					<th class="tableleft">网点地址：</th>
					<td class="tableright" colspan="3"><input id="brchAddress" style="width: 80%;" name="brchAddress" type="text" class="textinput"/></td>
				</tr>
				<tr>
					<th class="tableleft">传真：</th>
					<td class="tableright"><input id=fax name="fax" type="text" class="textinput easyui-validatebox"/></td>
					<th class="tableleft">描述：</th>
					<td colspan="3" class="tableright"><textarea class="textinput" name="description"  style="width: 80%;height: 100px;"></textarea></td>
				</tr>
				<tr>
				 	<th class="tableleft">是否金融市民卡领卡网点：</th>
					<td class="tableright"><input id="isLkBrch" name="isLkBrch" type="text" class="textinput"/></td>
					<th class="tableleft">是否全功能卡领卡网点：</th>
					<td class="tableright"><input id="isLkBrch2" name="isLkBrch2" type="text" class="textinput"/></td>
					<td class="tableright" colspan="2"></td>
				</tr>
			</table>
		</form>
	</div>
</div>