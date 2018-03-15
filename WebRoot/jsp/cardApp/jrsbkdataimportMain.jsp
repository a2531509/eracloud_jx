<%--
  Created by IntelliJ IDEA.
  User: yangn
  Date: 2016-09-12
  Time: 10:54:35
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
    var $grid;
    var isExt;
    var totNum = 0;
    var sucNum = 0;
    var errNum = 0;
    var newApplyNums = 0;
    var hfApplyNums = 0;
    var applyNums = 0;
    var notApplyNums = 0;
    $(function(){
    	$("#synGroupIdTip").tooltip({
			position:"top",    
			content:"<span style='color:#B94A48'>是否只申领新卡</span>" 
		});
		$("#onlyAppNewCard").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否",
            onChange:function(checked){
            	if(checked){
            		$("#onlyAppHFCard").switchbutton("uncheck");
            	}
            }
		});
		
		$("#synGroupIdTip2").tooltip({
			position:"top",    
			content:"<span style='color:#B94A48'>是否只申领换发卡</span>" 
		});
		$("#onlyAppHFCard").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否",
            onChange:function(checked){
            	if(checked){
            		$("#onlyAppNewCard").switchbutton("uncheck");
            	}
            }
		});
    	
        initCal();
        createSysBranch(
            {id:"brchId"},
            {id:"userId"}
        );
        createLocalDataSelect({
        	id:"state",
        	data:[
        	    {value:"",text:"请选择"},
        	    {value:"0",text:"初始导入"},
        	    {value:"1",text:"已比对"},
        	    {value:"2",text:"申领过程中"},
        	    {value:"3",text:"已申领"}
        	]
        });
        $grid = createDataGrid({
            id:"dg",
            url:"cardapply/cardApplyAction!toQueryJrsbkImportData.action",
            border:false,
            fit:true,
            pagination:true,
            pageSize:20,
            rownumbers:true,
            striped:true,
            scrollbarSize:0,
            singleSelect:false,
            fitColumns:true,
            columns:[[
                {field:"",checkbox:true},
                {field:"DEAL_NO",title:"流水号",sortable:true, width:parseInt($(this).width() * 0.06)},
                {field:"DEALDATE",title:"导入时间",sortable:true,width:parseInt($(this).width() * 0.12)},
                {field:"TOT_NUMS",title:"总数量",sortable:true,width:parseInt($(this).width() * 0.05)},
                {field:"SUC_NUMS",title:"比对成功数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"ERR_NUMS",title:"比对失败数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"NEW_APPLY_NUMS",title:"新制卡数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"HF_APPLY_NUMS",title:"换发卡数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"APPLY_NUMS",title:"申领成功数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"NOT_APPLY_NUMS",title:"申领失败数量",sortable:true,width:parseInt($(this).width() * 0.08)},
                {field:"STATETYPE",title:"状态",sortable:true,width:parseInt($(this).width() * 0.06)},
                {field:"FULLNAME",title:"导入网点",sortable:true, width:parseInt($(this).width() * 0.15)},
                {field:"USERNAME",title:"导入柜员",sortable:true}
            ]],
            onLoadSuccess:function(data){
                if(data.status != 0){
                    $.messager.alert("系统消息",data.errMsg,"error");
                    return;
                }
                initCal();
                updateFooter();
            },
            onCheck:function(index,data){
                calRow(true,data);
                updateFooter();
            },
            onUncheck:function(index,data){
                calRow(false,data);
                updateFooter();
            },
            onCheckAll:function(rows){
                initCal();
                for(var i=0,hk=rows.length;i < hk;i++){
                    var data  = rows[i];
                    calRow(true,data);
                }
                updateFooter();
            },
            onUncheckAll:function(rows){
                initCal();
                updateFooter();
            }
        })
    });
    function query(){
        var params = 
        {
            "rec.dealNo":$("#dealNo").val(),
            "rec.brchId":$("#brchId").combotree("getValue"),
            "rec.userId":$("#userId").combobox("getValue"),
            "beginTime":$("#startDate").val(),
            "endTime":$("#endDate").val(),
            "queryType":"0",
            "rec.dealState":$("#state").combobox("getValue"),
        };
        $grid.datagrid("load",params);
    }
    function initCal(){
        totNum = 0;
        sucNum = 0;
        errNum = 0;
        newApplyNums = 0;
        hfApplyNums = 0;
        applyNums = 0;
        notApplyNums = 0;
    }
    function calRow(is,data){
        if(is){
            totNum = parseFloat(totNum) + parseFloat(data.TOT_NUMS);
            sucNum = parseFloat(sucNum) + parseFloat(data.SUC_NUMS);
            errNum = parseFloat(errNum) + parseFloat(data.ERR_NUMS);
            newApplyNums = parseFloat(newApplyNums) + parseFloat(data.NEW_APPLY_NUMS);
            hfApplyNums = parseFloat(hfApplyNums) + parseFloat(data.HF_APPLY_NUMS);
            applyNums = parseFloat(applyNums) + parseFloat(data.APPLY_NUMS);
            notApplyNums = parseFloat(notApplyNums) + parseFloat(data.NOT_APPLY_NUMS);
        }else{
            totNum = parseFloat(totNum) - parseFloat(data.TOT_NUMS);
            sucNum = parseFloat(sucNum) - parseFloat(data.SUC_NUMS);
            errNum = parseFloat(errNum) - parseFloat(data.ERR_NUMS);
            newApplyNums = parseFloat(newApplyNums) - parseFloat(data.NEW_APPLY_NUMS);
            hfApplyNums = parseFloat(hfApplyNums) - parseFloat(data.HF_APPLY_NUMS);
            applyNums = parseFloat(applyNums) - parseFloat(data.APPLY_NUMS);
            notApplyNums = parseFloat(notApplyNums) - parseFloat(data.NOT_APPLY_NUMS);
        }
    }
    function updateFooter(){
        $grid.datagrid("reloadFooter",[
            {"DEALDATE":"本页信息统计:","TOT_NUMS":totNum,"SUC_NUMS":sucNum,"ERR_NUMS":errNum,"NEW_APPLY_NUMS":newApplyNums,"HF_APPLY_NUMS":hfApplyNums,"APPLY_NUMS":applyNums,"NOT_APPLY_NUMS":notApplyNums}
        ]);
    }
    function openimportwin(){
        $.modalDialog({
            title:"金融市民卡导入申领",
            iconCls:"icon-import",
            fit:false,
            maximized:false,
            shadow:false,
            closable:false,
            maximizable:false,
            width:700,
    		height:250,
            href:"jsp/cardApp/jrsbkdataimportAdd.jsp",
            tools:[{
                iconCls:"icon_cancel_01",
                handler:function(){
                    $.modalDialog.handler.dialog("destroy");
                    $.modalDialog.handler = undefined;
                }
            }],
            buttons:[
                {
                    text:"关闭",
                    iconCls:"icon-cancel",
                    handler:function(){
                        $.modalDialog.handler.dialog("destroy");
                        $.modalDialog.handler = undefined;
                    }
                }
            ]
        });
    }
    function saveImportData(){
        if($("#importFile").val() == ""){
            jAlert("请选择将要进行导入的文件！","warning");
            return;
        }
        $.messager.confirm("系统消息","您确认要导入选定的人员数据文件吗？",function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                commonDwr.uploadPersonDataFile(dwr.util.getValue("importFile"), "", function(data){
                    $.messager.progress("close");
                    if(!data){
                        jAlert("导入数据出现错误,系统未返回处理结果！");
                    }else if(data.status != '0'){
                        jAlert(data.errMsg);
                    }else {
                        jAlert("导入成功！","info",function(){
                            $.modalDialog.handler.dialog("destroy");
                            $.modalDialog.handler = undefined;
                        });
                        $grid.datagrid("reload");
                    }
                });
            }
        });
    }
    function toviewdata() {
        var rows = $grid.datagrid("getChecked");
        if(rows.length != 1){
            $.messager.alert("系统消息", "请选择一条要预览的记录！", "warning");
            return;
        }
        var dealNo = rows[0].DEAL_NO;
        $.modalDialog({
            title:"预览",
            fit:true,
            iconCls:"icon-viewInfo",
            maximized:true,
            maximizable:false,
            closable:false,
            href:"jsp/cardApp/jrsbkdataimportView.jsp?dealNo=" + dealNo,
            tools:[{
                iconCls:"icon_cancel_01",
                handler:function(){
                    $.modalDialog.handler.dialog("destroy");
                    $.modalDialog.handler = undefined;
                }
            }]
        });
    }
    function startcycle(){
        isExt = setInterval("startDetect()",800);
    }
    function startDetect(){
        commonDwr.isDownloadComplete("jrsbkdataimportmainexport",function(data){
            if(data["returnValue"] == '0'){
                clearInterval(isExt);
                jAlert("导出成功！","info",function(){
                    $.messager.progress("close");
                });
            }
        });
    }
    function exportdata() {
        var rows = $grid.datagrid("getChecked");
        if (rows.length != 1) {
            $.messager.alert("系统消息", "请选择一条要导出的记录！", "warning");
            return;
        }
        $.messager.confirm("系统消息", "您确定要导出选中的人员数据？", function(r) {
            if(r){
                $.messager.progress({text:"正在进行导出, 请稍候..."});
                $("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
                $("#downloadcsv").attr("src","cardapply/cardApplyAction!saveJrsbkImportDataExport.action?rec.dealNo=" + rows[0].DEAL_NO);
                startcycle();
            }
        });
    }
    function deletedata(){
        var rows = $grid.datagrid("getChecked");
        if (rows.length != 1) {
            $.messager.alert("系统消息", "请选择一条记录进行删除！", "warning");
            return;
        }
        $.messager.confirm("系统消息","您确定要删除勾选的记录信息吗？",function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                $.post("cardapply/cardApplyAction!saveDeleteJrsbkImportData.action",{"rec.dealNo":rows[0].DEAL_NO},function(data,status){
                    $.messager.progress("close");
                    if(status == "success"){
                        if(dealNull(data.status) == "0"){
                            jAlert("删除成功！","info",function(){
                                $grid.datagrid("reload");
                            });
                        }else{
                            jAlert(dealNull(data.errMsg));
                        }
                    }else{
                        jAlert("请求出现错误，请重新进行操作！");
                    }
                },"json");
            }
        })
    }
    function toapplydata(){
        var rows = $grid.datagrid("getChecked");
        //不可多文件处理
        if (rows.length != 1) {
            $.messager.alert("系统消息","请勾选一条记录进行申领！","warning");
            return;
        }
        var ids = "";
        for(var i = 0;i < rows.length;i++){
            if(rows[i].STATE != '1' && rows[i].STATE != '2'){
                jAlert("勾选的记录中流水编号【" + rows[i].DEAL_NO + "】的记录的状态不是【已比对或申领过程中】状态","warning");
                return;
            }
            ids = ids + rows[i].DEAL_NO + ",";
        }
        if(dealNull(ids) != ""){
            ids = ids.substring(0,ids.length - 1);
        }
        if(dealNull(ids) == ""){
            jAlert("请勾选将要进行申领的记录信息！","warning");
            return;
        }
        var tempTitle = "您确定要申领勾选的记录信息吗？<br/><span style='color:red;'>已勾选" + rows.length + "个导入文件。</span>";
        $.messager.confirm("系统消息",tempTitle,function(r){
            if(r){
                $.messager.progress({text:"数据处理中, 请稍候..."});
                $.post("cardapply/cardApplyAction!saveJrsbkImportDataApply.action",{"selectedId":ids, onlyAppNewCard:$("#onlyAppNewCard").prop("checked"), onlyAppHFCard:$("#onlyAppHFCard").prop("checked")},function(data,status){
                    $.messager.progress("close");
                    if(status == "success"){
                        if(dealNull(data.status) == "0"){
                            jAlert("申领成功","info",function(){
                                $grid.datagrid("reload");
                            });
                        }else{
                            jAlert(dealNull(data.errMsg));
                        }
                    }else{
                        jAlert("请求出现错误，请重新进行操作！");
                    }
                },"json");
            }
        })
    }
    function downloadTemplate(){
        $("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
		$("#downloadcsv").attr("src","/cardapply/cardApplyAction!downloadTemplate.action?template=jrsbkimport");
	}
</script>
<n:initpage title="金融市民卡申领数据进行导入操作！">
    <n:center>
        <div id="tb" style="padding: 2px 0">
            <table class="tablegrid" cellpadding="0" cellspacing="0" width="100%">
                <tr>
               		<td class="tableleft">流水号：</td>
                    <td class="tableright"><input id="dealNo" class="textinput" maxlength="10"></td>
                    <td class="tableleft">网点：</td>
                    <td class="tableright"><input id="brchId" class="textinput"></td>
                    <td class="tableleft">柜员：</td>
                    <td class="tableright"><input id="userId" class="textinput"></td>
                    <td class="tableleft">处理状态：</td>
                    <td class="tableright"><input id="state" class="textinput" type="text"></td>
                </tr>
                <tr>
                    <td class="tableleft">起始时间：</td>
                    <td class="tableright"><input id="startDate" class="textinput Wdate" onclick="WdatePicker({dataFormat:'yyyy-MM-dd', readOnly:true, maxDate:'#F{$dp.$D(\'endDate\') || \'%y-%M-%d\'}'})"></td>
                    <td class="tableleft">结束时间：</td>
                    <td class="tableright"><input id="endDate" class="textinput Wdate" onclick="WdatePicker({dataFormat:'yyyy-MM-dd', readOnly:true, minDate:'#F{$dp.$D(\'startDate\')}', maxDate:'%y-%M-%d'})"></td>
                    <td class="tableright" colspan="4">
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" onclick="query()">查询</a>
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" onclick="openimportwin()">导入</a>
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" onclick="toviewdata()">预览</a>
                        &nbsp;
						<span id="synGroupIdTip">
							<input id="onlyAppNewCard" name="onlyAppNewCard" type="checkbox">
						</span>
						<span id="synGroupIdTip2">
							<input id="onlyAppHFCard" name="onlyAppHFCard" type="checkbox">
						</span>
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" onclick="toapplydata()">申领</a>
                        &nbsp;
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-remove" onclick="deletedata()">删除</a>
                        <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" onclick="exportdata()">导出</a>
                    </td>
                </tr>
            </table>
        </div>
        <table id="dg" title="申领数据导入"></table>
    </n:center>
</n:initpage>