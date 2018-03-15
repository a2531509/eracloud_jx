<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $ftpFileMsg;
	$(function(){
		$ftpFileMsg = createDataGrid({
			id:"ftpFileMsg",
			url:"taskManagement/taskManagementAction!queryFileMsgFromFtp.action",
			border:false,
			fit:true,
			fitColumns:true,
			scrollbarSize:0,
			pageList:[50,80,100,150,200,300,500],
			remoteSort:false,
			pagination:false,
			singleSelect:false,
			columns:[[
			    {field:"selectId",title:"id",sortable:true,checkbox:true},
			    {field:"fileType",title:"文件类型",sortable:true,formatter:function(value,row,index){
			    	if(value == "-"){
			    		return "文件";
			    	}else if(value == "d"){
			    		return "文件夹";
			    	}else if(value == "l"){
			    		return "链接";
			    	}else{
			    		return "其他";
			    	}
			    }},
				{field:"fileName",title:"文件名称",sortable:true,width : parseInt($(this).width() * 0.12)},
				{field:"fileSize",title:"文件大小",sortable:true,order:"asc",width:parseInt($(this).width() * 0.08),sorter:function(a,b){
					if(parseFloat(a) >= parseFloat(b)){
						return 1;
					}else{
						return -1;
					}
				}},
				{field:"modifyDate",title:"最后修改时间",sortable:false,width:parseInt($(this).width() * 0.08)},
			]],
			toolbar:[
				{
					iconCls:"icon-reload",
					text:"刷新",
					handler:function(){
						$ftpFileMsg.datagrid("load",{queryType:"0"});
					}
				},
				{
					iconCls:"icon-edit",
					text:"勾选导入",
					handler:function(){
						selectImport();
					}
				},
				{
					iconCls:"icon-sum",
					text:"全部导入",
					handler:function(){
						allImport();
					}
				}
			]
		});
	});
	function uploadFile(){
		var filePath =  $("#importFile").val();
		if(dealNull(filePath).length <= 0){
			$.messager.alert("系统消息","请选择需要进行导入的文件！","error");
			return;
		}
		filePath = filePath.toLowerCase();
		var matchExp = /^.{1,}(\.txt|\.txt)$/g;
		if(matchExp.test(filePath)){
			$.messager.confirm("系统消息","您确定要导入该制卡返回文件吗？",function(r){
				if(r){
					$.messager.progress({text:"正在进行文件导入..."});
					commonDwr.saveMakeCardData(dwr.util.getValue("importFile"),"",{callback:function(data){
						$.messager.progress("close");
						if(data["status"] == "0"){
							$.messager.alert("系统消息","导入成功！共导入" + data["totalNum"] + "条数据！","info");
						}else{
							$.messager.alert("系统消息",data["errMsg"],"error");
						}
					},errorHandler:function(errorMsg){
						$.messager.alert("系统消息","导入文件时出现错误，请检查文件格式是否符合并重试,或联系系统管理员！" + errorMsg,"error",function(){
							$.messager.progress("close");
						});
					}});
				}
			});
		}else{
			$.messager.alert("系统消息","选择导入文件的格式不符合要求，请重新进行选择！","error");
		}
	}
	function selectImport(){
		var allRows = $ftpFileMsg.datagrid("getChecked");
		if(!allRows || allRows.length <= 0){
			$.messager.alert("系统消息","请选择需要导入的文件！","error");
			return;
		}
		var selectId = "";
		for(var i = 0;i < allRows.length;i++){
			if(allRows[i].fileType == "-"){
				selectId += allRows[i].fileName;
				if(i != (allRows.length - 1)){
					selectId += ","
				}
			}else{
				$.messager.alert("系统消息","选择的文件中不能含有非文本文件！","error");
				return;
			}
		}
		$.messager.confirm("系统消息","您确定要导入选定的制卡返回文件吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行数据处理，请稍候..."});
				$.ajax({
					url:"taskManagement/taskManagementAction!saveBatchImportMakeCardData.action",
					type:"post",
					dataType:"json",
					data:{selectIds:selectId,queryType:"0"},
					timeout:0,
					async:true,
					success:function(data){
						if(data["status"] == "0"){
							$.messager.alert("系统消息",data["errMsg"],"info",function(){
								$ftpFileMsg.datagrid("reload");
							});
						}else{
							$.messager.alert("系统消息",data["errMsg"],"error");
						}
					},
					error:function(XMLHttpRequest, textStatus, errorThrown){
						$.messager.alert("系统消息",textStatus,"error");
					},
					complete:function(XMLHttpRequest,textStatus){
						$.messager.progress("close");
					}
				});
			}
		});
	}
	function allImport(){
		$.messager.confirm("系统消息","您确定要导入所有的制卡返回数据吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行数据处理，请稍候..."});
				$.ajax({
					url:"taskManagement/taskManagementAction!saveBatchImportMakeCardData.action",
					type:"post",
					dataType:"json",
					data:{queryType:"1"},
					timeout:0,
					async:true,
					success:function(data){
						if(data["status"] == "0"){
							$.messager.alert("系统消息",data["errMsg"],"info",function(){
								$ftpFileMsg.datagrid("reload");
							});
						}else{
							$.messager.alert("系统消息",data["errMsg"],"error");
						}
					},
					error:function(XMLHttpRequest, textStatus, errorThrown){
						$.messager.alert("系统消息",textStatus,"error");
					},
					complete:function(XMLHttpRequest,textStatus){
						$.messager.progress("close");
					}
				});
			}
		});
	}
</script>
<n:initpage title="制卡返回文件进行导入操作！<span style='color:red'>注意：</span>只有任务状态为【制卡中】且导入文件的制卡明细数量和制卡任务的数量一致才能进行导入操作！">
	<n:center cssClass="datagrid-toolbar" layoutOptions="title:'制卡文件导入'">
		<div class="easyui-tabs" style="width:100%" data-options="pill:false,fit:true">
			<div class="datagrid-toolbar" title="本地文件导入" data-options="border:false,fit:true">
				<form id="importFileForm">
					<table style="width:100%" class="tablegrid datagrid-toolbar">
						<tr>
							<td style="text-align:center;height:30px;">
								<table style="margin: 0 auto;width:500px;">
									<tr>
										<td colspan="4" style="heght:30px;">
											<input id="importFile" name="importFile" type="file" style="width:500px;" accept="text/plain"/>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td style="text-align:center;height:30px;">
								<table style="margin: 0 auto;width:500px;">
									<tr>
										<td colspan="4" style="heght:30px;">
											<a data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="uploadFile()">上传</a>
										</td>
									</tr>
								</table>
							<td>
						</tr>
					</table>
				</form>
			</div>
			<div class="datagrid-toolbar" title="FTP文件导入">
				<table id="ftpFileMsg" title="FTP文件信息"></table>
			</div>
		</div>
	</n:center>
</n:initpage>