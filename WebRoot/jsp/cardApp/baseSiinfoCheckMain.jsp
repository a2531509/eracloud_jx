<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	var isExt;
	$(function(){
		if("${defaultErrorMsg}" != ""){
			jAlert("${defaultErrorMsg}");
		}
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				toQuery();
			}
		});
		$("#hasPhoto").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			editable:false,
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"是"},
				{value:"1", text:"否"}
			]
		});
		createRegionSelect(
			{id:"regionId",panelMaxHeight:200},
			{id:"townId"},
			{id:"commId"}
		);
		createSysCode({
			id:"slfs",
		    codeType:"APPLY_WAY",
		    codeValue:"1,2",
		    isShowDefaultOption:false,
		    value:"1",
		    onSelect:function(node){
		 		if(node.VALUE == "2"){
		 			$("#sqapply").css("display","table-row");
		 			$("#sqapply").find("input").prop("disabled", false);
					$("#dwapply").css("display","none");
					$("#dwapply").find("input").prop("disabled", true);
		 		}else if(node.VALUE == "1"){
		 			$("#sqapply").css("display","none");
					$("#sqapply").find("input").prop("disabled", true);
					$("#dwapply").css("display","table-row");
					$("#dwapply").find("input").prop("disabled", false);
		 		}
		 	}
		});
		$grid = createDataGrid({
			id:"dg",
			url:"personInfoErrata/personInfoErrataAction!queryErrataPerson.action",
			fit:true,
			border:false,
			pageList:[20,50,100,500,1000,2000],
			singleSelect:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
		      	{field:"CUSTOMER_ID1",sortable:true,checkbox:true},
		    	{field:"CUSTOMER_ID",title:"市民卡人员编号",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CERT_NO",title:"身份证",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"RESIDE_TYPE",title:"户籍",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"CORP_CUSTOMER_ID",title:"单位编号",sortable:false,width:parseInt($(this).width()*0.1)},
		    	{field:"CORP_NAME",title:"单位名称",sortable:true,width:parseInt($(this).width()*0.1)},
		    	{field:"SURE_FLAG",title:"信息比对标志位",sortable:false,width:parseInt($(this).width()*0.1), hidden:true},
		    	{field:"PHOTO",title:"照片标志位",sortable:false,width:parseInt($(this).width()*0.1)}
		    ]]
		});
	});
	function autoCom(){
        if($("#corpId").val() == ""){
            $("#corpName").val("");
        }
        $("#corpId").autocomplete({
            source: function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"customerId":$("#corpId").val(),jugeCorp:true},function(data){
                    response($.map(data.rows,function(item){return {label:item.LABEL,value:item.TEXT}}));
                },'json');
            },
            select: function(event,ui){
                $('#corpId').val(ui.item.label);
                $('#corpName').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
	
	function autoComByName(){
        if($("#corpName").val() == ""){
            $("#corpId").val("");
        }
        $("#corpName").autocomplete({
            source:function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"corpName":$("#corpName").val(),jugeCorp:true},function(data){
                    response($.map(data.rows,function(item){return {label:item.TEXT,value:item.LABEL}}));
                },'json');
            },
            select: function(event,ui){
                $('#corpId').val(ui.item.value);
                $('#corpName').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	function toQuery(){
		var away = $("#slfs").combobox("getValue");
		if(away == "1" || away == "2"){
			if(away == "2"){//社区申领
				if(dealNull($("#regionId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择人员所属区域","error",function(){
						$("#regionId").combobox("showPanel");
					});
					return;
				}
				if(dealNull($("#townId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择人员所属乡镇（街道）","error",function(){
						$("#townId").combobox("showPanel");
					});
					return;
				}
				if(dealNull($("#commId").combobox("getValue")) == ""){
					$.messager.alert("系统消息","请选择人员所属社区（村）","error",function(){
						$("#commId").combobox("showPanel");
					});
					return;
				}
			}else if(away == "1"){//单位申领
				if(dealNull($("#corpId").val()) == ""){
				    $.messager.alert("系统消息","请输入单位编号或选择单位类型！","error");
					return;
				}
			}
			var params = getformdata("searchConts");
			params["corpName"] = dealNull($("#corpName").val());
			params["queryType"] = "0";
			$grid.datagrid("load",params);
		}else{
			$.messager.alert("系统消息","请选择申领方式！","error");
			return;
		}
		
	}
	function toExp(){
		var allRows = $grid.datagrid("getChecked");
		var customerIds = "";
		if(allRows && allRows.length > 0) {
			for( var i = 0; i < allRows.length; i++) {
				if(i != allRows.length - 1){
					customerIds = customerIds + allRows[i].CUSTOMER_ID1 + ",";
				}else{
					customerIds = customerIds + allRows[i].CUSTOMER_ID1;
				}
			}
			$("#customerIds").val(customerIds);
			jConfirm("您确定要导出勾选的勘误数据吗 ？",function(){
				$.messager.progress({text:"正在进行导出,请稍候..."});
				$("#searchConts").get(0).action = "personInfoErrata/personInfoErrataAction!expPersonErrata.action";
				$("#searchConts").get(0).submit();
				startCycle();
			});
		}else{
			jConfirm("您确定要导出当前所有数据吗 ？",function(){
				$.messager.progress({text:"正在进行导出,请稍候..."});
				$("#searchConts").get(0).action = "personInfoErrata/personInfoErrataAction!expPersonErrata.action";
				$("#searchConts").get(0).submit();
				startCycle();
			});
		}
	}
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("expPersonErrataDownloadSuc",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	function getQueryLimit(){
		var params = "";
		var allRows = $grid.datagrid("getChecked");
		var customerIds = "";
		if(dealNull($("#slfs").combobox("getValue"))!=""){
			params = params + "slfs="+dealNull($("#slfs").combobox("getValue"));
		 }
		 if(dealNull($("#corpId").val())!=""){
			params = params + "&corpId="+dealNull($("#corpId").val());
		 }
		 if(dealNull($("#corpName").val())!=""){
			params = params + "&corpName="+dealNull($("#corpName").val());
		 }
		 if(dealNull($("#regionId").combobox("getValue"))!=""){
			params = params + "&regionId="+dealNull($("#regionId").combobox("getValue"));
		 }
		 if(dealNull($("#townId").combobox("getValue"))!=""){
			params = params + "&townId="+dealNull($("#townId").combobox("getValue"));
		 }
		 if(dealNull($("#commId").combobox("getValue"))!=""){
			params = params + "&commId="+dealNull($("#commId").combobox("getValue"));
		 }
		 if(dealNull($("#beginDate").val())!=""){
			params = params + "&beginDate="+dealNull($("#beginDate").val());
		 }
		 if(dealNull($("#endDate").val())!=""){
			params = params + "&endDate="+dealNull($("#endDate").val());
		 }
		 if(allRows && allRows.length > 0){
			for ( var i = 0; i < allRows.length; i++) {
				if(i != allRows.length - 1){
					customerIds = customerIds + allRows[i].CUSTOMER_ID1 + ",";
				}else{
					customerIds = customerIds + allRows[i].CUSTOMER_ID1;
				}
			}
			$("#customerIds").val(customerIds);
			params = params + "&customerIds=" + customerIds;
		 }
		 return params;
	}
	function printTotalAndMx(){
		var allRows = $grid.datagrid("getChecked");
		$.messager.confirm("系统消息","您确定要生成勘误数据汇总明细清单？",function(r){
			if(r){
				$.messager.progress({text:"数据处理中，请稍后...."});
				$.post("personInfoErrata/personInfoErrataAction!printTotalCorrigendumData.action?"+getQueryLimit(),function(rsp,status){
					$.messager.progress("close");
					if(rsp.status){
						showReport("嘉兴市民卡勘误数据汇总明细清单",rsp.actionNo);
					}else{
						jAlert(rsp.message);
					}
				},"json");
			}
		});
	}
</script>
<n:initpage title="查询单位/社区未制卡人员，并导出其中不符合申领条件的进行勘误操作">
  	<n:center>
		<div id="tb">
			<form id="searchConts" method="post">
				<input id="customerIds" name="customerIds" type="hidden">
		        <table class="tablegrid">
					<tr>
						<td class="tableleft">申领方式：</td>
						<td class="tableright"><input name="slfs"  class="textinput" id="slfs" type="text" value="2"/></td>
						<td class="tableleft">出生年月始：</td>
						<td class="tableright"><input id="beginDate" name="beginDate" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">出生年月止：</td>
						<td class="tableright"><input id="endDate" name="endDate" class="Wdate textinput" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyyMMdd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">是否有照片：</td>
						<td class="tableright"><input id="hasPhoto" name="hasPhoto" class="textinput" type="text" /></td>
					</tr>
					<tr id="dwapply" style="display:table-row;">
						<td class="tableleft">单位编号：</td>
						<td class="tableright"><input id="corpId" name="corpId" class="textinput" type="text" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpName" name="corpName" class="textinput" type="text" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">&nbsp;</td>
						<td class="tableright">&nbsp;</td>
						<td colspan="2" style="text-align:center;">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-excel'"  onclick="toExp()">导出</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-print'" onclick="printTotalAndMx();">打印</a>
						</td>
					</tr>
					<tr id="sqapply" style="display:none;">
					 	<td class="tableleft">所属区域：</td>
						<td class="tableright"><input name="regionId"  class="textinput"  id="regionId"  type="text" style="width:174px;"/></td>
						<td class="tableleft">乡镇(街道)：</td>
						<td class="tableright"><input name="townId"  class="textinput" id="townId"  type="text" style="width:174px;"/></td>
						<td class="tableleft">社区(村)：</td>
						<td class="tableright"><input name="commId"  class="textinput easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
						<td colspan="2" style="text-align:center;">
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-search'"  onclick="toQuery()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-excel'"  onclick="toExp()">导出</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-print'" onclick="printTotalAndMx();">打印</a>
						</td>
					</tr>
			    </table>
		    </form>
		</div>
  		<table id="dg" title="未制卡人员信息"></table>
	</n:center>
</n:initpage>