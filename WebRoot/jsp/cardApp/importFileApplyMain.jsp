<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<script type="text/javascript">
    var row;
	var $grid;
  	$(function() {
  		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
  		
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$grid = createDataGrid({
			id:"dg",
			url:"cardapply/cardApplyAction!findViewApply.action",
			pagination:true,
			rownumbers:true,
			border:false,
			fit:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			striped:true,
			columns:[[
			    {field:"XH",title:"序号",width:parseInt($(this).width()*0.03),sortable:true},
	           	{field:"CERT_NO",title:"证件号码",width:parseInt($(this).width()*0.1),sortable:true},
	            {field:"NAME",title:"姓名",width:parseInt($(this).width()*0.05),sortable:true},
	            {field:"MED_WHOLE_NO",title:"统筹区编码",width:parseInt($(this).width()*0.05),sortable:true},
	            {field:"EMP_NAME",title:"任务名称",width:parseInt($(this).width()*0.10),sortable:true,align:"left"},
	            {field:"NOTE",title:"校验",width:parseInt($(this).width()*0.20),sortable:true,align:"left"}
	        ]],toolbar:'#tb', onLoadSuccess:function(data){
			       	 $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=true; } });//初始话默认不选中
			       	 if(dealNull(data["status"]) != 0){
			       		 $.messager.alert('系统消息',data.errMsg,'error');
			       	 }else{
			       	     $grid.datagrid("selectRow",0);
			       		  $("#applyIds").val(data.applyIds);
			       	  }
		      	}
		});
	});
 	function query(){
 		//if($("#certNo").val() == "" && $("#name").val() == "") {
 			///$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：证件号码或姓名</div>","warning");
 			//return;
 		//}
		$grid.datagrid("load",{
			queryType:"0",
			clientName:$("#name").val(), 
			certNo:$("#certNo").val()
		});
    }
function tofileUploadApply(){
	$.modalDialog({
		title: "按身份证号批量导入申领",
		width:800,
		height:250,
		resizable:false,
		href:"jsp/cardApp/importApplyView.jsp",
		onLoad: function() {
			var f = $.modalDialog.handler.find("#form");
			f.form("load", {
				"applyIds": rows[0].applyIds
			});
		},
		buttons:[{
			text:"保存",
			iconCls:"icon-ok",
			handler:function() {
				fileUploadApply();
			}
		},{
			text:"取消",
			iconCls:"icon-cancel",
			handler:function() {
				$.modalDialog.handler.dialog("destroy");
			    $.modalDialog.handler = undefined;
			}
		}]
	});
 }
 
 	function exportImpViewApply() {
 	var applyIds=$("#applyIds").val();
		$.messager.confirm("系统消息","您确定要导出选中的申领数据？",function(r){
			if(r){
				$("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
				$("#downloadcsv").attr("src","/cardapply/cardApplyAction!exportImpViewApply.action?applyIds="+applyIds);
			}
		});
		
	}
//新增或是编辑保存
function saveImpApply(){
	var applyIds=$("#applyIds").val();
	if(dealNull(applyIds) == ""){
	    $.messager.alert("系统消息","请查询预览申领人员信息！","error");
		return;
	}
	$.messager.confirm("系统消息","您确定要全部申领吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("/cardapply/cardApplyAction!saveImpApply.action", 
				{applyIds:$('#applyIds').val()},
				 function(data){
					 $.messager.progress('close');
			     	if(data.status == '0'){
			     		$.messager.alert('系统消息','保存成功','info',function(){
			     			$dg.datagrid('reload');
			     		});
			     	}else{
			     		$.messager.alert('系统消息',data.errMsg,'error');
			     	}
			 },"json");
		 }
	});
}
</script>
<n:initpage title="人员进行导入申领！<span style='color:red'>注意：</span>导入文件格式为*.xls且文件必须符合特定格式！">
	<n:center cssClass="datagrid-toolbar">
	    <div id="tb" style="padding:2px 0">
			<form id="importFileForm">
			<input type="hidden" name="applyIds" id="applyIds" value="${applyIds}"/>
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="width: 8%">证件号码：</td>
						<td class="tableright" style="width: 17%"><input id="certNo" type="text" class="textinput easyui-validatebox" name="certNo" validtype="idcard" maxlength="18"/></td>
						<td class="tableleft" style="width: 8%">姓名：</td>
						<td class="tableright" style="width: 17%"><input id="name" type="text" class="textinput easyui-validatebox" name="name" maxlength="30"/></td>
						<td style="padding-left:3px; width: 50%">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="tofileUploadApply();">导入上传</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="exportImpViewApply();">预览下载</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="saveImpApply();">确认申领</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="申领客户信息"></table>
	</n:center>
</n:initpage>