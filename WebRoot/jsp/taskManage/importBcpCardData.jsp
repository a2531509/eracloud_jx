<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<style>
	.tableleft{font-weight:600}
</style>
<script type="text/javascript">
	if("${defaultErrorMsg}" != ""){
		jAlert("${defaultErrorMsg}");
	}
    function uploadFile(){
    	if($("#importMadeCardFile").val() == ""){
    		jAlert("请选择半成品卡制卡返回数据文件！","warning",function(){
    			$("#importMadeCardFile").click();
    		});
    		return;
    	}
    	$.messager.confirm("系统消息","您确定要导入半成品卡制卡返回数据文件吗？",function(r){
			if(r){
				$.messager.progress({text:"正在进行制卡文件导入，请稍后..."});
				commonDwr.saveImportFgxhCgData(dwr.util.getValue("importMadeCardFile"),{callback:function(data){
					$.messager.progress("close");
					if(data["status"] == "0"){
						jAlert("文件导入成功！数量：" + data.importCount,"info");
					}else{
						jAlert(data["errMsg"]);
					}
				},errorHandler:function(errorMsg,www){
					jAlert("导入文件时出现错误，请检查文件格式是否符合并重试,或联系系统管理员！" + errorMsg + "," + www,"error",function(){
						$.messager.progress("close");
					});
				}});
			}
		});
    }
</script>
<n:initpage title="半成品卡制卡返回数据文件进行导入操作！">
	<n:center cssClass="datagrid-toolbar" layoutOptions="title:'半成品卡制卡返回数据文件导入'">
		<form id="importFileForm">
			<table style="width:100%" class="tablegrid datagrid-toolbar">
				<tr>
					<td style="text-align:center;height:30px;">
						<table style="margin: 0 auto;width:700px;">
							<tr>
								<td class="tableleft">半成品卡制卡返回数据文件：</td>
								<td class="tableright" colspan="4" style="heght:30px;">
									<input id="importMadeCardFile" name="importMadeCardFile" type="file" style="width:500px;" accept="text/plain"/>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td style="text-align:center;height:50px;">
						<a data-options="plain:false,iconCls:'icon-trans'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="uploadFile()">导入</a>
					</td>
				</tr>
			</table>
		</form>
	</n:center>
</n:initpage>