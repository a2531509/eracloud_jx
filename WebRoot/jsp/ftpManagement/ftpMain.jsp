<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	$(function(){
		$("#div_dialog").dialog({
			title : "FTP配置",
			width : 400,
		    height : 300,
		    modal: true,
		    closed : true,
		    isAdd : true,
		    toolbar : "#tb_edit",
			onClose : function(){
			},
			onBeforeOpen : function(){
				var isAdd = $(this).dialog("options").isAdd;
				if(isAdd){
					$("#dg_edit").datagrid("loadData", [
					   	{key:"ftp_use", value:""}, 
					   	{key:"host_ip", value:"1.1.1.1"}, 
					   	{key:"host_port", value:"21"}, 
					   	{key:"user_name", value:"username"}, 
					   	{key:"pwd", value:"password"}, 
					   	{key:"ftp_note", value:"备注"}]);
					$("#dg_edit").datagrid('beginEdit', 0);
				} else {
					var row = $("#dg").datagrid("getSelected");
					if(!row){
						jAlert("请选择编辑项！", "warning");
						return;
					}
					delete row["V_V"];
					var arr = new Array();
					for(var i in row){
						arr.push({key:i, value:row[i]});
					}
					$("#dg_edit").datagrid("loadData", arr);
				}
			}
		});
		
		$("#dg_edit").datagrid({
			fitColumns : true,
			fit : true,
			rownumbers : true,
			border : false,
			striped : true,
			singleSelect : true,
			editRow : -1,
			columns : [[
				{field:"",checkbox:true},
				{field:"key",title:"配置项", width:parseInt($(this).width()*0.05), editor:{type:'validatebox', options:{required:true}}},
				{field:"value",title:"值", width:parseInt($(this).width()*0.05), editor:{type:'validatebox', options:{required:true}}}
			]],
			onSelect : function(index, row) {
				var editRow = $(this).datagrid("options").editRow;
				if(editRow >= 0 && editRow != index){
					$(this).datagrid('endEdit', editRow);
				}
				$(".edit_modify").linkbutton("enable");
			},
			onUnSelect : function() {
				$(".edit_modify").linkbutton("disable");
			},
			onLoadSuccess : function(){
				$(this).datagrid("options").editRow = -1;
				initDataGrid();
			},
			onDblClickRow : function(index,field,value){
				$(this).datagrid('beginEdit', index);
			},
			onBeforeEdit : function(index, row){
				var editRow = $(this).datagrid("options").editRow;
				// alert("before:" + editRow);
				if(editRow >= 0){
					$(this).datagrid('endEdit', editRow);
				}
				$(this).datagrid("options").editRow = index;
			},
			onBeginEdit : function(index, row){
				// var editRow = $(this).datagrid("options").editRow;
				// alert("begin:" + editRow);
				var cellEdit = $(this).datagrid('getEditor', {index:index, field:'key'});
				var $input = cellEdit.target;
				if($input.val() == "ftp_use"){
					$input.prop('readonly', true);
				}
				$(this).datagrid("selectRow", index);
				$(this).datagrid("scrollTo", index);
			},
			onEndEdit : function(index, row, changes){
				// var editRow = $(this).datagrid("options").editRow;
				// alert("end:" + editRow);
				$(this).datagrid("options").editRow = -1;
				initDataGrid();
			}
		});
		
		$("#dg").datagrid({
			url : "ftp/ftpAction!findFtpConfList.action",
			fitColumns : true,
			fit : true,
			pagination : true,
			rownumbers : true,
			border : false,
			striped : true,
			toolbar : "#tb",
			pageList : [20, 30, 40, 50, 100],
			singleSelect : true,
			idField : "FTP_USE",
			columns : [[
				{field:"",checkbox:true},
				{field:"ftp_use", title:"配置项", sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"host_ip", title:"IP地址", width:parseInt($(this).width()*0.08)},
				{field:"host_port", title:"端口", width:parseInt($(this).width()*0.05)},
				{field:"user_name", title:"用户名", width:parseInt($(this).width()*0.08)},
				{field:"pwd",title:"密码", width:parseInt($(this).width()*0.08)},
				{field:"ftp_note",title:"备注", width:parseInt($(this).width()*0.2)}
			]],
			onSelect : function() {
				$(".modify").linkbutton("enable");
			},
			onUnSelect : function() {
				$(".modify").linkbutton("disable");
			},
			onBeforeLoad : function(params) {
				$(this).datagrid("clearSelections");
				$(".modify").linkbutton("disable");
				if (!params.query) {
					return false;
				}
			},
			onLoadSuccess : function(data) {
				if (data.status != 0) {
					jAlert(data.errMsg, "warning");
				}
			}
		});
	})

	function query() {
		$("#dg").datagrid("load", {
			query : true,
			ftpUse : $("#ftpUse").val()
		})
	}
	function add() {
		$("#div_dialog").dialog("options").isAdd = true;
		$("#div_dialog").dialog("open");
	}
	function edit() {
		$("#div_dialog").dialog("options").isAdd = false;
		$("#div_dialog").dialog("open");
	}
	function remove() {
		var row = $("#dg").datagrid("getSelected");
		if(!row){
			jAlert("请选择删除项！", "warning");
			return;
		}
		$.messager.confirm("提示", "确定删除FTP配置【" + row.ftp_use + "】吗？", function(r){
			if(r){
				$.messager.progress({text:"数据处理中..."});
				$.post("ftp/ftpAction!deleteFtpConf.action", {ftpUse:row.ftp_use}, function(res){
					$.messager.progress("close");
					if(res.status == 1){
						jAlert(res.errMsg, "error");
					} else {
						jAlert("删除FTP配置项成功!", "info", function(){
							$("#div_dialog").dialog("close");
							query();
						});
					}
				}, "json"); 
			}
		});
	}
	
	// edit
	function initDataGrid(){
		$("#dg_edit").datagrid("clearSelections");
		$(".edit_modify").linkbutton("disable");
	}
	function editAdd(){
		if(!$("#dg_edit").datagrid("validateRow", 0)){
			jAlert("有不合法的配置项！", "warning");
			return;
		}
		$("#dg_edit").datagrid("appendRow", {key:"", value:""});
		var len = $("#dg_edit").datagrid("getData").total;
		$("#dg_edit").datagrid("beginEdit", len - 1);
	}
	function editEdit(){
		var index = $("#dg_edit").datagrid("getRowIndex", $("#dg_edit").datagrid("getSelected"));
		$("#dg_edit").datagrid("beginEdit", index);
	}
	function editRemove(){
		var index = $("#dg_edit").datagrid("getRowIndex", $("#dg_edit").datagrid("getSelected"));
		$("#dg_edit").datagrid("deleteRow", index);
		initDataGrid();
	}
	function editSave(){
		var data = $("#dg_edit").datagrid("getData");
		if(data.total == 0){
			jAlert("该FTP配置项为空！", "warning");
			return;
		} else if (!$("#dg_edit").datagrid("validateRow", $("#dg_edit").datagrid("options").editRow)){
			jAlert("有不合法的配置项！", "warning");
			return;
		}
		var options = $("#dg_edit").datagrid("options");
		$("#dg_edit").datagrid("endEdit", options.editRow);
		
		//
		$.messager.confirm("提示", "确定保存该FTP配置？", function(r){
			if(r){
				var confArr = data.rows;
				var params = new Object();
				params.isAdd = $("#div_dialog").dialog("options").isAdd;
				for(var i in confArr){
					params["ftpConf['" + confArr[i].key + "']"] = confArr[i].value;
				}
				$.messager.progress({text:"数据处理中..."});
				$.post("ftp/ftpAction!saveFtpConf.action", params, function(res){
					$.messager.progress("close");
					if(res.status == 1){
						jAlert(res.errMsg, "error");
					} else {
						jAlert("保存FTP配置成功!", "info", function(){
							$("#div_dialog").dialog("close");
							query();
						});
					}
				}, "json");
			}
		});
	}
</script>
<n:initpage title="FTP配置进行管理！">
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<form id="searchConts">
				<table style="width: auto;">
					<tr>
						<td>FTP配置项：</td>
						<td style="padding-right: 3px"><input  id="ftpUse" type="text" class="textinput" name="ftpUse" /></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-add'" href="javascript:void(0);" class="easyui-linkbutton" onclick="add()">添加</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-edit',disabled:true" href="javascript:void(0);" class="easyui-linkbutton modify" onclick="edit()">编辑</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-remove',disabled:true" href="javascript:void(0);" class="easyui-linkbutton modify" onclick="remove()">删除</a></td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="FTP配置"></table>
  	</n:center>
  	<div id="div_dialog">
  		<table id="dg_edit"></table>
  		<div id="tb_edit" class="datagrid-toolbar">
			<form id="searchConts">
				<table style="width: auto;">
					<tr>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-add'" href="javascript:void(0);" class="easyui-linkbutton" onclick="editAdd()">添加</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-edit',disabled:true" href="javascript:void(0);" class="easyui-linkbutton edit_modify" onclick="editEdit()">编辑</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-remove',disabled:true" href="javascript:void(0);" class="easyui-linkbutton edit_modify" onclick="editRemove()">删除</a></td>
						<td><div class="datagrid-btn-separator"></div></td>
						<td><a style="text-align:center;margin:0 auto;" data-options="plain:true,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="editSave()">保存</a></td>
					</tr>
				</table>
			</form>
		</div>
  	</div>
</n:initpage>